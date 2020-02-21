{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
module Lib
    ( startApp
    ) where

import Data.Aeson
import Data.Aeson.TH
import Network.Wai.Handler.Warp
import Servant

import WaiHelpers
import Stage
import Env

data User = User
  { userId        :: Int
  , userFirstName :: String
  , userLastName  :: String
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''User)

type API = "users" :> Get '[JSON] [User] :<|> Raw

startApp :: IO ()
startApp = do
  port <- portFromEnv
  env <- stageFromEnv
  () <- putStrLn $ "Stage: " ++ show env
  run port $ app env

app :: Stage -> Application
app stage = sslRedirect stage . corsMiddleware $ serve api server


api :: Proxy API
api = Proxy
server :: Server API
server = return users :<|> serveDirectoryWith (staticSettings "react")
users :: [User]
users = [ User 1 "Isaac" "Newton"
        , User 2 "Albert" "Einstein"
        , User 3 "Stephen" "Hawking"
        ]
