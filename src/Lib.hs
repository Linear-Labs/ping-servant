{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TemplateHaskell #-}


module Lib where

--import Data.Text
import Servant
import Data.List
import qualified Data.Text as T


import Network.Wai
import Network.Wai.Handler.Warp -- necessary to call run

import Data.Aeson -- this has stuff for working with JSON
import Data.Aeson.TH -- this allows using the template haskell way to derive toJSON from an ADT declaration.


-- There is some convention going on.  "users" will give the api via /users?sortby=<Age or Name>
-- QueryParam x y makes an API where you do ?x=(something of type y)
type UserAPI = "users" :> QueryParam "sortby" SortBy :> Get '[JSON] [User]

data SortBy = Age | Name

instance FromHttpApiData SortBy where 
  parseQueryParam txt = case T.unpack txt of 
    "Age" -> Right Age 
    "Name" -> Right Name 
    _ -> Left $ T.pack "you, suck"

data User = User {
  name :: String,
  age :: Int
}

-- the magic that actually does the conversion of adts to JSON
$(deriveJSON defaultOptions ''User)


users = [User "Ben" 12, User "Moe" 10]

startApp :: IO ()
startApp = run 8080 app


{-
What is an Application?
-}
app :: Application
app = serve api server

{-
What things are the Proxy type?
-}
api :: Proxy UserAPI
api = Proxy

{-
What is Server API
Where is the server monad defined
-}
-- server :: Server UserAPI

-- handlers coming from the queryparam combinator
-- have the property that the link may have been well formed
-- thus we are comparingon maybe a thing
server = myhandler 
  where
    myhandler sorter =  return $ sortBy (sortme sorter) users

sortme sorter (User name1 age1) (User name2 age2) = case sorter of 
  -- when using queryparam, figure out exactly what is going on..
  -- is our instance of httpjson being used?
  -- It's clear that sorter is the entity handed in from the network.
  -- So we just need to tell our server/process what to do in this case.
  Just Name -> compare  name1 name2
  Just Age -> compare age1 age2
  -- need to correctly handle Nothing.  The correct way to handle Nothing is to lift an error to the ServantErr type
