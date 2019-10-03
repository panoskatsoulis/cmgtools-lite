import ROOT, argparse

parser = argparse.ArgumentParser(description='Check a list of files if they are corrupted.')
parser.add_argument('files', metavar='file', nargs='+', help="files to check")
parser.add_argument('--log', type=str, action='store', help="filename to create filename.log", required=True)
args = parser.parse_args()

##print(args.files)
log = open(args.log+".log","w+")

file_has_issue = False
for f in args.files:
    if ROOT.TFile.Open(f):
        print("File "+f+" has openned.")
    else:
        print("File "+f+" has failed to open.")
        file_has_issue = True
        log.write(f+"\n")

log.close()
if file_has_issue:
    quit(1)
quit(0)
