pragma solidity ^0.5.0;

/*
Main smart contract, the core of the whole solution.
This contract holds mapping of the users (donors/investors and community members, it provides users with tokens, 
gets the inputs into the ecosystem performance evaluation function and computes its output (not implemented yet).
It also holds the list of tasks the users can claim for themselves and then mark as complete. Certain tasks can be 
created as verified by external sensor, in that case the Oracle node needs to trigger the completion of the task.
After a task is claimed as complete, the members of the community vote if the task was really completed or not. If yes,
the member who completed it will be rewarded.
*/
import "./CETHi.sol";
import "./CETHc.sol";
import "./wwefc.sol";
import "./projectVoting.sol";

contract mainState {
    
    address private _owner; 
    uint private _budget = 0;
    uint private _stateResult = 0;
    uint private _stakeholderReview;
    uint private _stakeholderWeight;
    uint private _tasksInfluence;
    uint private _tasksWeight;
    uint private _sensorOutput;
    uint private _sensorWeight;
    uint private _projectShare = 0;
    uint private _exchRate;
    uint private _totalCommunityMembers = 0;
    address private _ProjContrAddr;
    CETHiToken public tokenContractInvestor;
    CETHcToken public tokenContractCommunity;
    EuroWWFcoin public tokenContractReward;
    projectVoting public contractProjectVoting;

    constructor (CETHiToken _tokenContractInvestor, CETHcToken _tokenContractCommunity, EuroWWFcoin _tokenContractReward, projectVoting _contractProjectVoting ) public payable {
        _owner = msg.sender;
        _exchRate = 1;
        tokenContractInvestor = _tokenContractInvestor;
        tokenContractCommunity = _tokenContractCommunity;
        tokenContractReward = _tokenContractReward;
        contractProjectVoting = _contractProjectVoting;
    }

    function _computeState() internal returns (uint) {
        _stateResult = 0;
        return _stateResult;
    }

    function updateSensorMetrics(uint _sensorData) internal {
        _sensorOutput = _sensorData;
    }

    function updateStakeholderMetrics(uint _stakeholderMetrics) internal {
        require ( _stakeholderMetrics <= 100);
        //uint userId = _userToID[msg.sender];
        require ( _platformUsers[msg.sender].role == 1 );
        _stakeholderReview = _stakeholderMetrics;
    }

    function changeExchRate(uint _newExchRate) external {
        require(msg.sender == _owner);
        _exchRate = _newExchRate;
    }

    /*
    function changeProjectContract(address _newProjContrAddr) external {
        require(msg.sender == _owner);
        _exchRate = _newProjContrAddr;
    }
    */

    function changeWeights(uint _weight1, uint _weight2, uint _weight3) external {
        require(isStakeholder());
        _stakeholderWeight = _weight1;
        _tasksWeight = _weight2;
        _sensorWeight = _weight3;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function isStakeholder() public view returns (bool) {
        //uint userId = _userToID[msg.sender];
        return ( _platformUsers[msg.sender].role == 1 );
    }

    /*
    struct for users who will acess the system
    role:
    0 - community member
    1 - donor (voting rights)
    2 - investor (voting rights)
    moneyPaid = how much money this user got paid out
    bankCode - ID of the bank account of the user to get rewards
    */
    struct User {
        string name;
        address ethaddr;
        uint role;
        uint moneyPaid;
        uint bankCode;
    }


    //User[] internal _platformUsers;
    //mapping (address => uint) _userToID;
    mapping (address => User) _platformUsers;

    /* 
    struct for the tasks, fields are task name, date done
    state:
    0 - not done and not claimed
    1 - not done and claimed
    2 - done-candidate
    3 - done
    5 - rejected
    dbpointer - placeholder for object link in the DB
    stateInfluence - weight of the done tasks on the main state of ecosystem
    tokenReward - how many tokens the user gets for the task done
    */
    struct Task {
        string name;
        uint state;
        uint dateDone;
        uint dbPointer;
        uint stateInfluence;
        uint tokenReward;
        bool votable;
        address taskClaimant;
    }

    string[] public platformTaskNames;
    mapping (uint => Task ) platformTasks;

    struct TaskVoting {
        uint eligibleVoters;
        uint votedAlready;
        uint votedYes;
        uint votedNo;
        bool open;
        mapping (address => bool) voters;
    } 

    mapping (uint => TaskVoting) private taskVotings;

    function initiateTaskVote(uint _taskId) internal {
        TaskVoting memory newTaskVoting = TaskVoting(_totalCommunityMembers, 0, 0, 0, true);
        taskVotings[_taskId] = newTaskVoting;
    }

    function voteForTask(uint _taskId, uint _vote) public {
        require(_platformUsers[msg.sender].role == 0);
        require(taskVotings[_taskId].voters[msg.sender] != true);

        taskVotings[_taskId].voters[msg.sender] = true;
        taskVotings[_taskId].votedAlready++;
        if (_vote == 0) {
            taskVotings[_taskId].votedNo++;
        }
        else {
            taskVotings[_taskId].votedYes++;
        }

        if ( taskVotings[_taskId].votedAlready > taskVotings[_taskId].eligibleVoters / 2) {
            taskVotings[_taskId].open == false;
            if (taskVotings[_taskId].votedYes > taskVotings[_taskId].votedNo) {
                completeTaskVote(_taskId);
            }
            else {
                rejectTaskVote(_taskId);
            }
            
        }
    }

    

    function addTask(string memory _name, uint _state, uint _dbpointer, uint _stateInfluence, uint _tokenReward, bool _votable) public {
        require(msg.sender == _owner);
        Task memory newTask = Task(_name, _state, 0, _dbpointer, _stateInfluence, _tokenReward, _votable, _owner);
        uint id = platformTaskNames.push(_name);
        platformTasks[id] = newTask;
    }

    function completeTaskSenor(uint _id, uint _result) public {
        require(msg.sender == platformTasks[_id].taskClaimant);
        require(platformTasks[_id].votable == false);
        if (_result == 1) {
            platformTasks[_id].state = 3;
            platformTasks[_id].dateDone = block.timestamp;
        }
        uint tokenReward = platformTasks[_id].tokenReward;
        _rewardUser(platformTasks[_id].taskClaimant, tokenReward, tokenReward);
        _tasksInfluence++;
    }

    function claimTask(uint _id) public {
        require(platformTasks[_id].state == 0);
        platformTasks[_id].state = 1;
        platformTasks[_id].taskClaimant = msg.sender;
    }
 
    function completeTaskCandidate(uint _id) public {
        require(msg.sender == platformTasks[_id].taskClaimant);
        require(platformTasks[_id].state == 1);
        platformTasks[_id].state = 2;
    }

    function completeTaskVote(uint _id) internal {
        platformTasks[_id].state = 3;
        uint tokenReward = platformTasks[_id].tokenReward;
        _rewardUser(platformTasks[_id].taskClaimant, tokenReward, tokenReward);
        _tasksInfluence++;
    }

    function rejectTaskVote(uint _id) internal {
        //do something here
        platformTasks[_id].state = 5;

    }

    function _addUser(string memory _name, address _address, uint _role, uint bankAddr) internal {
        User memory newUser = User(_name, _address, _role, 0, bankAddr);
        //uint id = _platformUsers.push(newUser) - 1;
        //_userToID[_address] = id;
        _platformUsers[_address] = newUser;
    }

    function addDonor(string calldata _name, address _address, uint _money, uint bankAddr) external {
        require(msg.sender == _owner);
        _addUser(_name, _address, 1, bankAddr);
        _budget += _money; 
        uint _tokens = _money * _exchRate;
        require(tokenContractInvestor.balanceOf(address(this)) >= _tokens);
        require(tokenContractInvestor.transfer(msg.sender, _tokens));
    }

    function addCommuneMember(string calldata _name, address _address,  uint bankAddr) external {
        require(msg.sender == _owner);
        _addUser(_name, _address, 0, bankAddr);
        require(tokenContractCommunity.balanceOf(address(this)) >= 100);
        require(tokenContractCommunity.transfer(msg.sender, 100));
        _totalCommunityMembers++;
    }

    function _rewardUser(address _address, uint _tokens, uint _money) internal {
        //userAddr = (address payable)_address;
        //userAddr.transfer(_tokens);
        require(tokenContractCommunity.balanceOf(address(this)) >= _tokens);
        require(tokenContractCommunity.transfer(msg.sender, _tokens));
        //uint userId = _userToID[_address];
        _platformUsers[_address].moneyPaid += _money;
        _budget -= _money;
        require(tokenContractReward.balanceOf(address(this)) >= _money);
        require(tokenContractReward.transfer(msg.sender, _money));
        //_sendMoney(_platformUsers[_address].bankCode,_money);
    }

    /*
    function _sendMoney(uint _bankCode, uint _money) internal {
        //foo
    }
    */



    function() external payable {}


}
