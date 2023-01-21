{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Lib
  ( listOpenPulls,
  listOpenPullDetails,
  filterConfilctPulls,
  formatPulls,
    getToken,
    getPull,
    makeRepo,
    GithubRepo,
    getRepoByEnv
  )
where

import Control.Monad.Trans.Except
import qualified GitHub as GH
import qualified GitHub.Data.Name as GH
import GitHub.Auth
import GitHub.Internal.Prelude
import System.Environment

import qualified System.Posix.Env.ByteString as EB
import qualified Data.Vector as V
import qualified Data.Text as T

import Data.Maybe


data GithubRepo = GithubRepo (GH.Name GH.Owner) (GH.Name GH.Repo) deriving (Show)


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

formatPull :: GH.PullRequest -> Text
formatPull pull = T.concat [GH.pullRequestTitle pull , GH.getUrl $ GH.pullRequestUrl pull]

formatPulls :: Vector GH.PullRequest -> Text
formatPulls pulls = T.concat $ V.toList $ fmap formatPull pulls

getToken :: IO GH.Auth
getToken = do
  token <- EB.getEnv "GITHUB_TOKEN"
  case token of
    Just t -> return $ GH.OAuth t
    Nothing -> return $ GH.OAuth ""

getRepoByEnv :: IO (Maybe GithubRepo)
getRepoByEnv = do
  repoName <- lookupEnv "GITHUB_REPOSITORY"
  return $  repoName >>= makeRepo . T.pack


makeRepo :: T.Text -> Maybe GithubRepo
makeRepo  repo = case T.splitOn "/" repo of
                [] -> Nothing
                [o,r] -> Just $ GithubRepo (GH.N o) (GH.N r)
                _ -> Nothing


