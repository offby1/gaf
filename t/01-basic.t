#!/bin/bash
#

# ----------------------------------------------------------------------
# basic test

# by this time ~/bin has "tsh" in it

die() { echo "$@" >&2; exit 1; }
warn() { echo "$@" >&2; }

export GAF_REPO=$HOME/gr
export GAF_FLIST=$HOME/gfl

t/setup

cd

tsh <<EOF

plan 87

## init and basics

gaf
    !ok
    /gaf -- gitify arbitrary files/

gaf init
    ok
    /Initialized empty Git repository in /home/\w+/gr/.git//
    /\[master \(root-commit\) [0-9a-f]{7}\] start/

gaf -h
    !ok
    /gaf -- gitify arbitrary files/

cd gr; git log --all --decorate
    ok
    /commit [0-9a-f]{40} \(HEAD, tag: start, master\)/
    /    start/

gaf foo
    !ok
    /git: \'foo\' is not a git command/

cd /tmp;gaf list
    ok
    /master/

cd /tmp; gaf save test foobar1
    ok
    /WARNING: \'foobar1\' does not exist\; skipping/

cd; cd gr;git log --all --decorate
    ok
    /commit [0-9a-f]{40} \(HEAD, tag: start, test, master\)/
    /    start/

cd; cd gr;git status
    ok
    /On branch test/
    /nothing to commit, working directory clean/

gaf list
    ok
    /master/
    /test/

cd; cd gr; git log --all
    ok
    /commit [0-9a-f]{40}/
    /    start/

cd; cd gr; git checkout master
    ok
    /Switched to branch \'master\'/

cd; cd gr; git branch -d test
    ok
    /Deleted branch test \(was [0-9a-f]{7}\)./

## save

cd
    ok

gaf save tsh gaftest/config
    ok
    /\[tsh [0-9a-f]{7}\] tsh: gaftest/config/
    / 3 files changed, 15 insertions\(\+\)/
    / create mode 100644 gaftest/config/fileA/
    / create mode 100644 gaftest/config/fileB/
    / create mode 100644 gaftest/config/fileC/

gaf list
    /master/
    /\* tsh/

gaf save tsh gaftest/local/tsh
    ok
    /\[tsh [0-9a-f]{7}\] tsh: gaftest/local/tsh/
    / 16 files changed, 2429 insertions\(\+\)/
    / create mode 100644 gaftest/local/tsh/COPYING/
    / create mode 100644 gaftest/local/tsh/doc/tsh.mkd/
    / create mode 100644 gaftest/local/tsh/html/gl-t12.html/
    / create mode 100644 gaftest/local/tsh/index.mkd/
    / create mode 100755 gaftest/local/tsh/t/t01-basics/
    / create mode 100755 gaftest/local/tsh/tsh/
    / create mode 100755 gaftest/local/tsh/tshrec/

gaf list
    /master/
    /\* tsh/

gaf list
    /master/
    /\* tsh/

cd gr; git log --all --decorate --oneline --graph
    ok
    /. [0-9a-f]{7} \(HEAD, tsh\) tsh: gaftest/local/tsh/
    /. [0-9a-f]{7} tsh: gaftest/config/
    /. [0-9a-f]{7} \(tag: start, master\) start/

## restore

cd
    ok

rm -rf lt ct
    ok

mv gaftest/local/tsh lt
    ok

mv gaftest/config ct
    ok

rm -f $GAF_FLIST
    ok

gaf restore tsh
    ok

diff -qr gaftest/local/tsh lt
    !ok
    /Only in lt: .git/

diff -qr gaftest/config ct
    ok

gaf restore tsh
    ok

diff -qr gaftest/local/tsh lt
    !ok
    /Only in lt: .git/

diff -qr gaftest/config ct
    ok

## restore lite

rm -rf gaftest/local/tsh
    ok

## update

gaf save tsh gaftest/config
    ok

echo "# " `date` >> gaftest/config/fileA
    ok

sleep 1
    ok

gaf save tsh gaftest/config
    ok
    /\[tsh [0-9a-f]{7}\] tsh: gaftest/config/
    / 1 file changed, 1 insertion\(\+\)/

gaf show --stat
    ok
    /commit [0-9a-f]{40}/
    /    tsh: gaftest/config/
    / gaftest/config/fileA | 1 /
    / 1 file changed, 1 insertion\(\+\)/

gaf list
    ok
    /master/
    /\* tsh/

EOF
