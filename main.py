from web3 import Web3
import json

infura_url = 'https://ropsten.infura.io/v3/20413552464f418b87bf181dab34f940'
address = '0x67B7ADdef4716E238582f38Ecff901A937427183'
contract_address = '0x1298B1A45b0d2a1C28Da0e283C1630F48BBaAd2e'
private_key = '800188b9b1a0af397eb808740a386ea3387ef29bf413e1de4d2c5fc326c0147d'

w3 = Web3(Web3.HTTPProvider(infura_url))
w3.eth.defaultAccount = address
balance = w3.eth.getBalance(address)
#print(w3.fromWei(balance, 'ether'))
with open('Test.abi') as f:
    abi = json.load(f)
contract = w3.eth.contract(address=contract_address, abi=abi)
nonce = w3.eth.getTransactionCount(address)

def getOwn():
    print(contract.functions.GetOwner.call())

def get_balance():
    balance = w3.eth.get_balance(address)
    print(w3.fromWei(balance, 'ether'))

def addEmpl(adr, name, role, phone):
    nonce = w3.eth.getTransactionCount(address)
    try:
        empl_tr = contract.functions.AddEmployee(adr, name, role, phone ).buildTransaction({
            'gas': 3000000,
            'gasPrice': w3.toWei('100', 'wei'),
            'from': address,
            'nonce': nonce,
        })
        signed_tr = w3.eth.account.signTransaction(empl_tr, private_key=private_key)
        w3.eth.sendRawTransaction(signed_tr.rawTransaction)
    except EOFError:
        print(EOFError)
    else:
        print("Success")
def editEmpl(adr, name ,role, phone):
    nonce = w3.eth.getTransactionCount(address)
    try:
        empl_tr = contract.functions.EditEmployee(adr, name, role, phone).buildTransaction({
            'gas': 3000000,
            'gasPrice': w3.toWei('100', 'wei'),
            'from': address,
            'nonce': nonce,
        })
        signed_tr = w3.eth.account.signTransaction(empl_tr, private_key=private_key)
        w3.eth.sendRawTransaction(signed_tr.rawTransaction)
    except EOFError:
        print(EOFError)
    else:
        print("Success: Employee Deleted")

def getEmpl(adr):
    print(contract.functions.GetEmployee(adr).call())

def delEmpl(adr):
    nonce = w3.eth.getTransactionCount(address)
    try:
        empl_tr = contract.functions.DeleteEmployee(adr).buildTransaction({
            'gas': 3000000,
            'gasPrice': w3.toWei('100', 'wei'),
            'from': address,
            'nonce': nonce,
        })
        signed_tr = w3.eth.account.signTransaction(empl_tr, private_key=private_key)
        w3.eth.sendRawTransaction(signed_tr.rawTransaction)
    except EOFError:
        print(EOFError)
    else:
        print("Success: Employee Deleted")

def addReq(r_type, adr, area, cost, new_owner):
    nonce = w3.eth.getTransactionCount(address)
    try:
        empl_tr = contract.functions.AddRequest(r_type, adr, area, cost, new_owner).buildTransaction({
            "gas": 3000000,
            "gasPrice": w3.toWei('1', 'wei'),
            "from": address,
            "nonce": nonce,
        })
        signed_tr = w3.eth.account.signTransaction(empl_tr, private_key=private_key)
        w3.eth.sendRawTransaction(signed_tr.rawTransaction)
    except EOFError:
        print(EOFError)
    else:
        print ("Succeess: Request Added")

def getReq():
    print(contract.functions.GetRequest().call())

def getHomelist():
    print(contract.functions.GetListHome().call())

def proReq(r_type, adr, area, cost, new_owner):
    try:
        nonce = w3.eth.getTransactionCount(address)
        empl_tr = contract.functions.ProcessRequest(id).buildTransaction({
            "gas": 3000000,
            "gasPrice": w3.toWei('1', 'wei'),
            "from": address,
            "nonce": nonce,
        })
        signed_tr = w3.eth.account.signTransaction(empl_tr, private_key=private_key)
        w3.eth.sendRawTransaction(signed_tr.rawTransaction)
    except EOFError:
        print(EOFError)
    else:
        print ("Succeess: Process Requested")

def getCost():
    print(contract.functions.GetCost().call())

#def editCost(price):
