import Data.List (sort, nub)
import Control.Monad (guard)

data GenoTypeElem = A | B | O deriving (Eq, Ord, Show)
data BloodType = BtA | BtB | BtO | BtAB deriving (Eq, Show)
data Quantifier = ALL | EXIST deriving (Eq, Show)
data Genos = Genos [GenoTypeElem] deriving (Eq, Show)
type ProbableGenos = [Genos]
data QGenos = QGenos Quantifier [ProbableGenos] deriving (Eq, Show)


(|+|) :: QGenos -> QGenos -> QGenos
(QGenos _ gls1) |+| (QGenos _ gls2) = QGenos EXIST . nub $ do
  gs1 <- gls1 :: [ProbableGenos]
  gs2 <- gls2 :: [ProbableGenos]
  Genos g1 <- gs1 :: ProbableGenos
  Genos g2 <- gs2 :: ProbableGenos
  ge1 <- g1 :: [GenoTypeElem]
  ge2 <- g2 :: [GenoTypeElem]
  return [Genos $ sort [ge1, ge2]]


(|-|) :: QGenos -> QGenos -> QGenos
childs@(QGenos _ proba_childs) |-| parent = QGenos EXIST . nub $ mhelper childs parent 
  where 
    mhelper (QGenos ALL real_childs) (QGenos ALL (p1:[])) = mmhelper (all) p1
    mhelper (QGenos EXIST real_childs) (QGenos ALL (p1:[])) = mmhelper (any) p1
    mhelper (QGenos ALL real_childs) (QGenos EXIST possible_parent) = concatMap (mmhelper (all)) possible_parent
    genosAll = nub [Genos $ sort [g1, g2] | g1 <- [A,B,O] , g2 <- [A,B,O]]
    mmhelper :: ((ProbableGenos -> Bool) -> [ProbableGenos] -> Bool) -> ProbableGenos -> [ProbableGenos]
    mmhelper quant_f p1 = do
      p2 <- genosAll  
      let (QGenos EXIST gs_possible) = (QGenos ALL [p1]) |+| (QGenos ALL [[p2]])
      guard $ quant_f (any (`elem` [g|g_proba <- gs_possible, g<-g_proba])) proba_childs
      return [p2]


blood2Geno :: BloodType -> ProbableGenos
blood2Geno bt = case bt of
  BtA  -> [Genos [A, O], Genos [A, A]]
  BtB  -> [Genos [B, O], Genos [B, B]]
  BtO  -> [Genos [O, O]]
  BtAB -> [Genos [A, B]]


main = do
  let mother = QGenos ALL [blood2Geno BtAB]
  let father = QGenos ALL [blood2Geno BtO]
  print $ mother |+| father
  -- output: QGenos EXIST [[Genos [A,O]],[Genos [B,O]]]


  let bros = QGenos ALL [[Genos [A, B]]]
  let father = QGenos ALL [[Genos [A, A]]]
  print $ bros |-| father
  -- output: QGenos EXIST [[Genos [A,B]],[Genos [B,B]],[Genos [B,O]]]

  let bros = QGenos ALL [[Genos [A, B]], [Genos [A, O]], [Genos [B, O]], [Genos [O, O]]]
  let father = QGenos ALL [[Genos [A, O]]]
  print $ bros |-| father
  -- output: QGenos EXIST [[Genos [B,O]]]

  let bros = QGenos ALL [[Genos [A, A]], [Genos [O, O]]]
  let m_mom = QGenos ALL [[Genos [A, A]]]
  let f_dad = QGenos ALL [[Genos [A, O]]]
  let f_mom = QGenos ALL [[Genos [A, A]]]

  let m_dad = (bros |-| (f_dad |+| f_mom)) |-| m_mom
  print m_dad
  -- output: QGenos EXIST [Genos [A,O],Genos [B,O],Genos [O,O]]

