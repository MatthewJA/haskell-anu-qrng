module ANUQRNG (
    randomWords, -- :: Integer -> MaybeT IO [Word8]
    randomWord -- :: MaybeT IO Word8
) where

import Network (withSocketsDo)
import Network.Connection
import Network.HTTP.Conduit

import Data.Aeson
import Data.Word

import Control.Applicative
import Control.Monad
import Control.Monad.Trans
import Control.Monad.Trans.Maybe
import Control.Monad.Trans.Resource

import qualified Data.Text as T


-- Models the response from the QRNG API.
data QRNGResponse = QRNGResponse {
    qrngType :: String,
    qrngLength :: Integer,
    qrngData :: [Word8],
    qrngSuccess :: Bool
} deriving (Show)

instance FromJSON QRNGResponse where
    parseJSON (Object v) =
        QRNGResponse <$> v .: T.pack "type"
                     <*> v .: T.pack "length"
                     <*> v .: T.pack "data"
                     <*> v .: T.pack "success"
    parseJSON _ = mzero


-- Base URL of the QRNG API.
apiUrl :: String
apiUrl = "https://qrng.anu.edu.au/API/jsonI.php"

-- Settings for the network Manager.
managerSettings :: ManagerSettings
managerSettings = mkManagerSettings tlsSettings sockSettings
    where
        tlsSettings = TLSSettingsSimple True False False
        sockSettings = Nothing

-- Form a request for n random words from the QRNG.
apiRequest :: Integer -> Maybe Request
apiRequest n = parseUrl $ apiUrl ++ "?length=" ++ show n ++ "&type=uint8"

-- Request n random words from the QRNG and return the parsed response.
sendApiRequest :: Integer -> MaybeT IO QRNGResponse
sendApiRequest n = (mapMaybeT withSocketsDo) . runResourceT $ do
    manager <- liftIO $ newManager managerSettings
    request <- liftMaybe $ apiRequest n
    response <- httpLbs request manager
    liftMaybe . decode . responseBody $ response
    where
        liftMaybe = lift . MaybeT . return

-- Fetch a list of random words from the QRNG.
randomWords :: Integer -> MaybeT IO [Word8]
randomWords n = fmap qrngData $ sendApiRequest n

-- Fetch a single random word from the QRNG.
randomWord :: MaybeT IO Word8
randomWord = fmap head $ randomWords 1
