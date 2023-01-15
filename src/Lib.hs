{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Lib
  ( listUsers,
    listPulls,
    getToken,
  )
where

import qualified GitHub as GH
import GitHub.Auth
import GitHub.Internal.Prelude
import System.Posix.Env.ByteString



listUsers :: GH.Name GH.User -> IO (Either GH.Error GH.User)
listUsers = GH.github' GH.userInfoForR

listPulls :: Auth -> GH.Name GH.Owner -> GH.Name GH.Repo -> IO (Either GH.Error (Vector GH.SimplePullRequest))
listPulls auth owner repo = GH.github auth $ GH.pullRequestsForR owner repo GH.optionsNoBase GH.FetchAll

getToken :: IO GH.Auth
getToken = do
  token <- getEnv "GITHUB_TOKEN"
  case token of Just t -> return $ GH.OAuth t
                Nothing -> return $ GH.OAuth ""
