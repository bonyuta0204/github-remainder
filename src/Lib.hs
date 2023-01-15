{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Lib
  ( listUsers,
  )
where

import qualified GitHub as GH
import Prelude.Compat

listUsers :: GH.Name GH.User -> IO (Either GH.Error GH.User)
listUsers = GH.github' GH.userInfoForR
