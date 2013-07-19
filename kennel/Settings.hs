-- | Settings are centralized, as much as possible, into this file. This
-- includes database connection settings, static file locations, etc.
-- In addition, you can configure a number of different aspects of Yesod
-- by overriding methods in the Yesod typeclass. That instance is
-- declared in the kennel.hs file.
module Settings
    ( widgetFile
    , staticRoot
    , staticDir
    , AppEnv (..)
    , Extra (..)
    , parseExtra
    , PersistConfig
    ) where

import Prelude
import Text.Shakespeare.Text (st)
import Language.Haskell.TH.Syntax
import Yesod.Default.Config
import Database.Persist.Sqlite (SqliteConf)
import qualified Yesod.Default.Util
import Data.Text (Text)
import Data.Yaml
import Control.Applicative
import System.Environment (getArgs, getProgName)
import System.Exit (exitFailure)

-- | Which Persistent backend this site is using.
type PersistConfig = SqliteConf

-- | The location of static files on your system. This is a file system
-- path. The default value works properly with your scaffolded site.
staticDir :: FilePath
staticDir = "static"

-- | The base URL for your static files. As you can see by the default
-- value, this can simply be "static" appended to your application root.
-- A powerful optimization can be serving static files from a separate
-- domain name. This allows you to use a web server optimized for static
-- files, more easily set expires and cache values, and avoid possibly
-- costly transference of cookies on static files. For more information,
-- please see:
--   http://code.google.com/speed/page-speed/docs/request.html#ServeFromCookielessDomain
--
-- If you change the resource pattern for StaticR in kennel.hs, you will
-- have to make a corresponding change here.
--
-- To see how this value is used, see urlRenderOverride in kennel.hs
staticRoot :: AppConfig e a ->  Text
staticRoot conf = [st|#{appRoot conf}/static|]

widgetFile :: String -> Q Exp
#if DEVELOPMENT
widgetFile = Yesod.Default.Util.widgetFileReload
#else
widgetFile = Yesod.Default.Util.widgetFileNoReload
#endif

-- Environment
data AppEnv = Development
            | Localhost
            | Production deriving (Read, Show, Enum, Bounded)

data Extra = Extra
    { extraCopyright :: Text
    , extraAuth :: Bool
    , extraSessionKey :: FilePath
    , extraSqliteSetting :: FilePath
    , extraCompilerConfig :: FilePath
    , extraAnalytics :: Maybe Text -- ^ Google Analytics
    }

parseExtra :: AppEnv -> Object -> Parser Extra
parseExtra _ o = Extra
    <$> o .:  "copyright"
    <*> o .:  "auth"
    <*> o .:  "session_key"
    <*> o .:  "sqlite_setting"
    <*> o .:  "compiler_config"
    <*> o .:? "analytics"

