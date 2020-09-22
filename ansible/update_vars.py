import jsbeautifier
import json
import os

def updateAnsiblehosts(data, hostsFileName):
    ipAddress = data['modules'][0]['outputs']['ocp4x-base-vm']['value'].strip('\n')
    print('ipAddress: ' +  ipAddress + '\n')
    cmd = "sed -i.bak 's/REPLACE_VPC_HOST/" + ipAddress + "/g' " + hostsFileName
    os.system(cmd)


def updateAnsibleVars(data, varsFilePath):
    clusterName = data['modules'][0]['outputs']['ocp4x-cluster-name']['value'].strip('\n')
    domainName = data['modules'][0]['outputs']['ocp4x-domain-name']['value'].strip('\n')
    pullSecret = data['modules'][0]['outputs']['ocp4x-pull-secret']['value'].strip('\n')
    sshPublicKey = data['modules'][0]['outputs']['ocp4x-ssh-public-key']['value'].strip('\n')

    print('clusterName: ' +  clusterName + '\n')
    print('domainName: ' +  domainName + '\n')
    print('pullSecret: ' +  pullSecret + '\n')
    print('sshPublicKey: ' +  sshPublicKey + '\n')

    with open(varsFilePath, 'r+') as f:
        file_source = f.read()
        replace_string = file_source.replace('REPLACE_PULL_SECRET', pullSecret).replace('REPLACE_SSH_PUBLIC_KEY', sshPublicKey)
        replace_string = replace_string.replace('REPLACE_DOMAIN_NAME', domainName).replace('REPLACE_CLUSTER_NAME', clusterName)
        
    with open(varsFilePath, 'w') as f:
        f.write(replace_string)
    

def main():

   # Read environment variables
   import os
   cwd = os.getcwd()
   stateFilePath = cwd + "/../terraform/terraform.tfstate"
   varsFilePath = cwd + "/group_vars/all"
   hostsFileName = cwd + "/hosts"
  
   response = jsbeautifier.beautify_file(stateFilePath)
   data = json.loads(response)

   #Update ansible group variables & hosts data
   updateAnsiblehosts(data, hostsFileName)
   updateAnsibleVars(data, varsFilePath)

if __name__== "__main__":
    main()

