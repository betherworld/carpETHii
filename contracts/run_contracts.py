
def deploy_contract_1(contract_interface, argument):
    """
    Instantiate functions that need a single argument for their constructors
    """
    # Instantiate and deploy contract
    contract = w3.eth.contract(
        abi=contract_interface['abi'],
        bytecode=contract_interface['bin']
    )
    # Submit transaction that deploys contract
    # currently w3.eth.accounts[0] is used as owner for all contracts
    tx_hash = contract.constructor(argument).transact({'from': w3.eth.accounts[0]})
    
    # Wait for transaction to be mined and get transaction receipt
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # Return contract address and contract abi
    return (tx_receipt['contractAddress'], contract_interface['abi'])

def deploy_contract_5(contract_interface, argument1, argument2, argument3, argument4):
    """
    Instantiate functions that need multiple arguments (5) for their constructors
    """
    # Instantiate and deploy contract
    contract = w3.eth.contract(
        abi=contract_interface['abi'],
        bytecode=contract_interface['bin']
    )
    # Submit transaction that deploys contract
    # currently w3.eth.accounts[0] is used as owner for all contracts
    tx_hash = contract.constructor(argument1, argument2, argument3, argument4).transact({'from': w3.eth.accounts[0]})
    
    # Wait for transaction to be mined and get transaction receipt
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # Return contract address and contract abi
    return (tx_receipt['contractAddress'], contract_interface['abi'])

from web3 import Web3
# create web3.py instance
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))

from solcx import compile_files
# compile all contract files (greeter.sol only for basic functionality check)
contracts = compile_files(['wwefc.sol','CETHc.sol', 'CETHi.sol', 'projectVoting.sol', 'mainState.sol', 'greeter.sol'])

main_contract = contracts.pop("mainState.sol:mainState")
project_voting = contracts.pop("projectVoting.sol:projectVoting")
investor_coin = contracts.pop("CETHi.sol:CETHiToken")
community_coin = contracts.pop("CETHc.sol:CETHcToken")
money_coin = contracts.pop("wwefc.sol:EuroWWFcoin")
greeter = contracts.pop("greeter.sol:Greeter")

# deploy all contracts
investor_coin_address = deploy_contract_1(investor_coin, 100000000)
community_coin_address = deploy_contract_1(community_coin, 100000000)
money_coin_address = deploy_contract_1(money_coin, 100000000)
project_voting_address = deploy_contract_1(project_voting, community_coin_address[0])
contract_address = deploy_contract_5(main_contract, investor_coin_address[0], community_coin_address[0], money_coin_address[0], project_voting_address[0])
greeter_address = deploy_contract_1(greeter, "hello ethereum!")

# ----------
# basic functionality examples

# get balance from nodes
print("Balance from selected node: " + str(w3.eth.getBalance(w3.eth.accounts[3])) + "\n")

# contract call
greet_instance = w3.eth.contract(address=greeter_address[0], abi=greeter_address[1])
print(greet_instance.functions.greet().call())



