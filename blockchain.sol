pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;


contract Owned {
    
    address payable private owner;
    
    constructor() public{
        owner = payable(msg.sender);
    }
    
    modifier OnlyOwner{
        require
        (
            msg.sender == owner,
            'Need to be owner'
        );
        _;
    }
    
    function ChangeOwner(address payable _owner) public OnlyOwner {
        owner = _owner;
    }
    
    function GetOwner() public returns (address){
        return owner;
    }
    
}


contract Test is Owned
{
    enum RequestType{NewHome, EditHome}
    enum OwnerOper{ChangeOwner, AddOwner}
    
    struct Ownership
    {
        string homeAddress;
        address owner;
        uint p;
    }    
    
    struct Owner{
        string name;
        uint passSer;
        uint passNum;
        uint256 date;
        string phoneNumber;
    }
    
    struct Home
    {
        string homeAddress;
        uint area;
        uint cost;
    }
    struct Request
    {
        address add;
        RequestType requestType;
        OwnerOper ownerOper;
        Home home;
    }
    struct Employee
    {
        string nameEmployee;
        string position;
        string phoneNumber;
        bool isset;
    }
    
    mapping(address => Employee) private employees;
    mapping(address => Owner) private owners;
    mapping(address => Request) private requests;
    mapping(string => Home) private homes;
    mapping(string => Ownership[]) private ownerships;
    
    Home[] homeList;
    address[] requestInitiator;
    
    uint private fee = 100 wei;
    
    function ChangeFee(uint _fee) public OnlyOwner
    {
        fee = _fee;
    }
    
    
    //---------------------------ModifierStart---------------------------------------
    
    modifier OnlyEmployee {
        require(
            employees[msg.sender].isset != false,
            'Only employee car run this function'
            );
        _;

    }
    
    modifier Costs(uint value){
        require(
            msg.value >= value,
            'Not enough funds!!'
            );
        _;
    }
    //---------------------------ModifiersEnd-----------------------------------------
    
    //-------------------------------HomeStart----------------------------------------
    
    function AddHome(string memory _adr, uint _area, uint _cost) OnlyEmployee public {
        Home memory h;
        h.homeAddress = _adr;
        h.area = _area;
        h.cost = _cost;
        homes[_adr] = h;
        homeList.push(h);
    }
    function GetHome(string memory adr) public returns (uint _area, uint _cost){
        return (homes[adr].area, homes[adr].cost);
    }
    
    function EditHome(string memory _adr, uint _newArea, uint _newCost) OnlyEmployee public {
        Home storage h = homes[_adr];
        h.area = _newArea;
        h.cost = _newCost;
    }
    
    
    function GetHomeList() public OnlyEmployee view returns (uint[] memory, string[] memory, uint[] memory, uint[] memory)
    {
        uint[] memory ids = new uint[](homeList.length);
        string[] memory homeAddresses = new string[](homeList.length);
        uint[] memory areas = new uint[](homeList.length);
        uint[] memory costs = new uint[](homeList.length);
        for(uint i=0; i < homeList.length ; i++){
            ids[i] = i;
            homeAddresses[i] = homeList[i].homeAddress;
            areas[i] = homeList[i].area;
            costs[i] = homeList[i].cost;
        }
        return( ids , homeAddresses , areas , costs );
    }
    
    //-------------------------------HomeEnd-------------------------------------------
    
    //-------------------------------EmployeeStart-------------------------------------
    
    function AddEmployee(address empl, string memory _nameEmployee, string memory _position, string memory _phoneNumber) public OnlyOwner{
        Employee memory e;
        e.nameEmployee = _nameEmployee;
        e.position = _position;
        e.phoneNumber = _phoneNumber;
        e.isset = true;
        employees[empl] = e;
    }
    
    function GetEmployee(address empl, string memory nameEmployee) public OnlyOwner returns (string memory _nameEmployee, string memory _position, string memory _phoneNumber){
        return (employees[empl].nameEmployee, employees[empl].position, employees[empl].phoneNumber);
    }
    
    function EditEmployee(address empl, string memory _nameEmployee, string memory _newPosition, string memory _newPhoneNumber) public OnlyOwner {
        Employee storage e = employees[empl];
        e.nameEmployee = _nameEmployee;
        e.position = _newPosition;
        e.phoneNumber = _newPhoneNumber;
    }
    function DeleteEmployee(address empl) public OnlyOwner returns(bool) {
        if(employees[empl].isset == true)
            {delete employees[empl];
            return true;
            }
        return false;
    }
    
    //-------------------------------EmployeeEnd-----------------------------------------
    
    //-------------------------------RequestStart----------------------------------------
    
    function AddRequest(uint rType, uint ownOpType, string memory homeAddress, uint area, uint cost, address newOwner) public Costs(fee) payable returns (bool){
        Home memory h;
        h.homeAddress = homeAddress;
        h.area = area;
        h.cost = cost;
        Request memory r;
        r.add = rType==0 ? address(0) : newOwner;
        r.requestType = rType == 0? RequestType.NewHome: RequestType.EditHome;
        r.ownerOper = ownOpType == 0? OwnerOper.ChangeOwner : OwnerOper.AddOwner;
        r.home = h; 
        requests[msg.sender] = r;
        requestInitiator.push(msg.sender);
    }
    
    function GetRequestList() public OnlyEmployee view returns (uint[] memory _ids, uint[] memory _types, uint[] memory _operTypes, string[] memory _homeAddresses)
    {
        uint[] memory ids = new uint[](requestInitiator.length);
        uint[] memory types = new uint[](requestInitiator.length);
        uint[] memory opTypes = new uint[](requestInitiator.length);
        string[] memory homeAddresses = new string[](requestInitiator.length);
        for(uint i=0;i!=requestInitiator.length;i++){
            ids[i] = i;
            types[i] = requests[requestInitiator[i]].requestType == RequestType.NewHome ? 0: 1;
            opTypes[i] = requests[requestInitiator[i]].ownerOper == OwnerOper.ChangeOwner ? 0: 1;
            homeAddresses[i] = requests[requestInitiator[i]].home.homeAddress;
        }
        return (ids, types, opTypes, homeAddresses);
    }
    
    function ProcessRequest(uint id) public OnlyEmployee{
        Request memory r = requests[requestInitiator[id]];
        if (r.requestType == RequestType.NewHome)
        {
            AddHome(r.home.homeAddress, r.home.area, r.home.cost);
            Ownership memory own;
            own.owner = r.add;
            own.homeAddress= r.home.homeAddress;
            ownerships[r.home.homeAddress].push(own);
            homeList.push(r.home);
            delete requests[requestInitiator[id]];
        }
        if (r.requestType == RequestType.EditHome)
        {
            EditHome(r.home.homeAddress, r.home.area, r.home.cost);
            if(r.ownerOper == OwnerOper.AddOwner)
            {
                EditHome(r.home.homeAddress, r.home.area, r.home.cost);
                Ownership memory own;
                own.owner = r.add;
                own.homeAddress= r.home.homeAddress;
                ownerships[r.home.homeAddress].push(own);
                delete requests[requestInitiator[id]];
            }
            else
            {
                EditHome(r.home.homeAddress, r.home.area, r.home.cost);
                Ownership memory own;
                own.owner = r.add;
                own.homeAddress= r.home.homeAddress;
                delete ownerships[r.home.homeAddress][0];
                ownerships[r.home.homeAddress].push(own);
                delete requests[requestInitiator[id]];
            }
        }
        
        
    }
    
    
    
    //-------------------------------RequestEnd------------------------------------------
    
    function GetOwnershipList() public view returns(string[] memory _homeAddresses, address[] memory _owners)
    {
        string[] memory homeAddresses = new string[](ownerships);
        address[] memory owners = new address[](requestInitiator.length);
        
        return(homeAddresses, types);
    }
    
}
