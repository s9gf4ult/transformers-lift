{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DefaultSignatures #-}
module Control.Monad.Trans.Lift.Local
    ( LiftLocal(..)
    , Local
    ) where

import Control.Monad.Trans.Class
import Control.Monad.Morph

import Control.Monad.Trans.Except
import Control.Monad.Trans.Identity
import Control.Monad.Trans.List
import Control.Monad.Trans.Maybe
import Control.Monad.Trans.Reader
import qualified Control.Monad.Trans.Cont          as Cont
import qualified Control.Monad.Trans.RWS.Lazy      as Lazy
import qualified Control.Monad.Trans.RWS.Strict    as Strict
import qualified Control.Monad.Trans.State.Lazy    as Lazy
import qualified Control.Monad.Trans.State.Strict  as Strict
import qualified Control.Monad.Trans.Writer.Lazy   as Lazy
import qualified Control.Monad.Trans.Writer.Strict as Strict

type Local r m a = (r -> r) -> m a -> m a

class MonadTrans t => LiftLocal t where
    liftLocal
        :: Monad m
        => m r
        -> (forall a . Local r    m  a)
        -> (forall a . Local r (t m) a)
    default liftLocal
        :: (Monad m, MFunctor t)
        => m r
        -> (forall a . Local r    m  a)
        -> (forall a . Local r (t m) a)
    liftLocal _ l f = hoist (l f)

instance LiftLocal (Cont.ContT r)
   where liftLocal = Cont.liftLocal

instance LiftLocal (ExceptT e)
instance LiftLocal IdentityT
instance LiftLocal ListT
instance LiftLocal MaybeT
instance LiftLocal (ReaderT r)
instance Monoid w => LiftLocal (Lazy.RWST r w s)
instance Monoid w => LiftLocal (Strict.RWST r w s)
instance LiftLocal (Lazy.StateT s)
instance LiftLocal (Strict.StateT s)
instance Monoid w => LiftLocal (Lazy.WriterT w)
instance Monoid w => LiftLocal (Strict.WriterT w)