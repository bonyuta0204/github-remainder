{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module GitHubClient
  ( listOpenPulls,
  listOpenPullDetails,
  filterConfilctPulls,
  runListUnMergeablePulls,
    getToken,
    getPull,
    makeRepo,
    GithubRepo,
    getRepoByEnv
  )
where

import           Control.Monad.Trans.Except
import qualified GitHub                      as GH
import           GitHub.Auth
import qualified GitHub.Data.Name            as GH
import           GitHub.Internal.Prelude
import           System.Environment

import qualified Data.Text                   as T
import qualified Data.Vector                 as V
import qualified System.Posix.Env.ByteString as EB

import           Data.Maybe


data GithubRepo = GithubRepo (GH.Name GH.Owner) (GH.Name GH.Repo) deriving (Show)

runListUnMergeablePulls :: IO (Either String [GH.PullRequest])
runListUnMergeablePulls = do
  token <- getToken
  repo <- getRepoByEnv
  case repo of
    Nothing -> return $ Left "could not get reqpositoy"
    Just r -> do
       res <- runExceptT $ listOpenPullDetails token r
       case res of
         Left err    -> return $ Left $ show err
         Right pulls -> return $ Right $ V.toList $ filterConfilctPulls pulls

listOpenPulls :: Auth -> GithubRepo -> ExceptT GH.Error IO (Vector GH.SimplePullRequest)
listOpenPulls auth (GithubRepo owner repo) = ExceptT $ GH.github auth $ GH.pullRequestsForR owner repo GH.stateOpen GH.FetchAll

getPull :: Auth -> GithubRepo -> GH.IssueNumber -> ExceptT GH.Error IO GH.PullRequest
getPull auth (GithubRepo owner repo) issueNumber = ExceptT $ GH.github auth $ GH.pullRequestR owner repo issueNumber

listOpenPullDetails :: Auth -> GithubRepo -> ExceptT GH.Error IO (Vector GH.PullRequest)
listOpenPullDetails auth repo = do
  pulls <- listOpenPulls auth repo
  let issueNumbers = fmap GH.simplePullRequestNumber pulls
  mapM (getPull auth repo) issueNumbers

filterConfilctPulls :: Vector GH.PullRequest -> Vector GH.PullRequest
filterConfilctPulls = V.filter ( not . fromMaybe True . GH.pullRequestMergeable )


getToken :: IO GH.Auth
getToken = do
  token <- EB.getEnv "GITHUB_TOKEN"
  case token of
    Just t  -> return $ GH.OAuth t
    Nothing -> return $ GH.OAuth ""

getRepoByEnv :: IO (Maybe GithubRepo)
getRepoByEnv = do
  repoName <- lookupEnv "GITHUB_REPOSITORY"
  return $  repoName >>= makeRepo . T.pack


makeRepo :: T.Text -> Maybe GithubRepo
makeRepo  repo = case T.splitOn "/" repo of
                []    -> Nothing
                [o,r] -> Just $ GithubRepo (GH.N o) (GH.N r)
                _     -> Nothing

