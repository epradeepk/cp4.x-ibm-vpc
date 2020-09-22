import ruamel.yaml
import subprocess
import os


def writeToYamlFile(path, fileName, data):
    filePathNameWExt = '/' + path + '/' + fileName + '.yaml'
    with open(filePathNameWExt, 'w') as fp:
        ruamel.yaml.dump(data, fp, Dumper=ruamel.yaml.RoundTripDumper)


def readYamlFile(path, fileName):
    filePathNameWExt = '/' + path + '/' + fileName + '.yaml'
    
    # The FullLoader parameter handles the conversion from YAML
    # scalar values to Python the dictionary format
    with open(filePathNameWExt, 'r') as file:
        return ruamel.yaml.load(file, Loader=ruamel.yaml.RoundTripLoader)


def getIpaddress(interface):
    cmd = "ip addr show " +  interface + " | awk '/inet/ {print $2}' | cut -d/ -f1 | head -1"

    try:
        ipAddress , ipError = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).communicate()
        return ipAddress
    except:
        raise Exception("Error on fetching systems Ipaddress")


def getDNSAddress(dnsPath):
    cmd = "cat " + dnsPath + " | grep -v '^#' | grep nameserver | awk '{print $2}'"

    try:
        dnsServer , dnsError = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).communicate()
        return dnsServer
    except:
        raise Exception("Error on fetching DNS server address")


def main():

   # Read environment variables
   netplanFilePath = os.getenv("NETPLAN_PATH")
   netplanFileName = os.getenv("NETPLAN_FILE_NAME")
   dnsFilePath = os.getenv("DNS_PATH")

   # Read the netplan yaml details
   netplanDetails = readYamlFile(netplanFilePath, netplanFileName)

   # Get ethernet interface details
   ethernets = netplanDetails['network']['ethernets'].keys()
   interface = ethernets[0]

   # Check if eth0 ethernet interface exists
   for ethernet in ethernets:
       if ethernet == 'eth0':
           interface = 'eth0'
           break
    
   if interface != 'eth0':
       interfacePos = list(netplanDetails['network']['ethernets'].keys()).index(interface)
       netplanDetails['network']['ethernets'].insert(interfacePos, 'eth0', netplanDetails['network']['ethernets'][interface])
       del netplanDetails['network']['ethernets'][interface]

       interface = 'eth0'
       netplanDetails['network']['ethernets'][interface]['set-name'] = interface
    
   
   # Check renderer key exits, if not create renderer key
   foundRenderer = 'false'
   if 'renderer' in netplanDetails['network'].keys():
       foundRenderer = 'true'

   if foundRenderer == 'false':
       pos = list(netplanDetails['network'].keys()).index('ethernets')
       netplanDetails['network'].insert(pos, 'renderer', 'networkd')

   
   # Check and fetch the Systems IPAddress & DNSAddress
   ipAddress = getIpaddress(interface)
   dnsAddress = getDNSAddress(dnsFilePath)

   # Add required keys to netplan
   netplanDetails['network']['ethernets'][interface]['dhcp4'] = 'no'
   netplanDetails['network']['ethernets'][interface]['addresses'] = [ipAddress.rstrip() + '/24']
   netplanDetails['network']['ethernets'][interface]['nameservers'] = {'addresses': [dnsAddress.rstrip()]}

   # Replace the content of netplan file
   writeToYamlFile(netplanFilePath, netplanFileName, netplanDetails)

   
if __name__== "__main__":
    main()


