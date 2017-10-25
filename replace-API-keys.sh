# This script will be EXECUTED running any (possibly unsave) commands in it
# It is expected to contain:
# SKEY_DUMMY='pattern for whatever test service key was by default in the sources'
#CKEY_DUMMY='pattern for whatever test client key was by defaut in the sources'
# SKEY='WorldPay service TEST key obtained on online.worldpay.com'
# CKEY='WorldPay client TEST key obtained on online.worldpay.com'
# With the keys your source will be modified 

# You can use this to find all the keys:
# grep -E T_[CS]_[a-f0-9-]\+ ~/wpw/test -r|sed 's/.*\(T_[CS]_[a-f0-9-]\+\).*/\1/g'|sort -u|awk '/^T_S_/{s=s"|"$1} /^T_C_/{c=c"|"$1} END{print "DUMMY_CKEYS=\"("substr(c,2)")\"\nDUMMY_SKEYS=\"("substr(s,2)")\"\n"}'>>replace-API-keys.sh

DUMMY_CKEYS='(T_C_03eaa1d3-4642-4079-b030-b543ee04b5af|T_C_0bd87243-a025-4517-a73e-00ad45735c26|T_C_97e8cbaa-14e0-4b1c-b2af-469daf8f1356)'
DUMMY_SKEYS='(T_S_3bdadc9c-54e0-4587-8d91-29813060fecd|T_S_77b08f82-b877-4989-b595-f2773ef1c831|T_S_f50ecb46-ca82-44a7-9c40-421818af5996)'

SKEY='T_S_420534f4-a7ff-4068-a188-7fa17ab07b3a'
CKEY='T_C_8d3c615f-af2e-4c29-963c-4d356220c517'

