{-# LANGUAGE TemplateHaskell #-}

module Main where

import Control.Monad (void)
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Control.Distributed.Process.Closure
import Control.Distributed.Process.Monitoring
import Control.Distributed.Process.Management
import Network.Transport.TCP


ping :: Process ()
ping = getSelfPid >>= register "ping"

pong :: Process ()
pong = getSelfPid >>= register "pong"

printAgent :: Process ()
printAgent = do
    mxAgent (MxAgentId "agent") emptyState handlers
    mxNotify (10 :: Int)
    where emptyState = 0 :: Int
          handlers = [ mxSink foo ]

foo :: Int -> MxAgent Int MxAction
foo n = (liftMX $ liftIO (print $ "hi" ++ show n)) >> mxReady

$(remotable ['ping, 'pong])
remotables = __remoteTable $ initRemoteTable

main :: IO ()
main = do
    Right (transport, _) <- createTransportExposeInternals "127.0.0.1" "8080" defaultTCPParameters
    localNode <- newLocalNode transport remotables
    pinger <- forkProcess localNode $ ping
    ponger <- forkProcess localNode $ pong
    runProcess localNode $ printAgent
    print "done"
