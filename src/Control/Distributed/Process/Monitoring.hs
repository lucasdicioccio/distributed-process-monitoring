
module Control.Distributed.Process.Monitoring (
        statsCollector
) where

import Control.Distributed.Process (Process, ProcessId, getSelfPid)

statsCollector :: Process ProcessId
statsCollector = getSelfPid
