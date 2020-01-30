from __future__ import print_function
from ROOT import TFile
## analysisTools, analysis helper functions

## tfile tool
def getTFileTree(_file,_tree):
    tf = TFile.Open(_file)
    if not tf:
        raise RuntimeError("File "+_file+" cannot be initialized.")
    if tf.IsZombie():
        raise RuntimeError("File "+_file+" is zombie.")
    print( tf.Get(_tree), tf.Get(_tree).GetNbranches() )
    return { "file": tf, "tree": tf.Get(_tree) }

## array from branch
def getBranchArray(_branch, _tree):
    from array import array
    res = array('d')
    _tree.SetBranchStatus("*",0)
    _tree.SetBranchStatus(_branch,1)
    for i in range(_tree.GetEntries()):
        _tree.GetEntry(i)
        res.append( getattr(_tree,_branch) )
    print( "Branch {}, type {}".format( _branch, type(getattr(_tree,_branch)) ) )
    print( res[0:5] )
    print()
    return res
