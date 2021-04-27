pragma solidity >=0.6.0 <=0.8.3;
pragma experimental ABIEncoderV2;

contract Owned{
    address payable private owner;
    constructor(){
        owner = payable(msg.sender);
    }
    modifier OnlyOwner{
        require(
            msg.sender == owner,
            'Only owner can run this function'
            );
        _;
    }
    function ChangeOwner(address payable newOwner) public OnlyOwner{
        owner = newOwner;
    }
    function GetOwner() public returns (address){
        return owner;
    }
}

contract Test is Owned
{
    enum RequestType{NewHome, EditHome}
    enum OwnerOperation {Add, Edit, Delete}
    uint private price = 100 wei;
    
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
        bool isset;
    }
    
    struct Home
    {
        string homeAddress;
        uint area;
        uint cost;
        bool isset;
    }
    struct Request
    {
        RequestType requestType;
        OwnerOperation operation;
        string homeAddress;
        uint area;
        uint result;
        address adr;
        uint cost;
        bool isProcessed;
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
    address[] requestInitiator;
    address[] ownersArray;
    address[] listHomeInitiator;
    mapping(address => Home) private homess;
    mapping(string => Home) private homes;
    string[] addresses;
    mapping(string => Ownership[]) private ownerships;
    
    uint private amount;
    
    modifier OnlyEmployee {
        require(
            employees[msg.sender].isset != false,
            'Only Employee can run this function'
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
    
    
    function AddHome(string memory _adr, uint _area, uint _cost) public {
        Home memory h;
        h.homeAddress = _adr;
        h.area = _area;
        h.cost = _cost;
        homess[msg.sender] = h;
        homes[_adr] = h;
        listHomeInitiator.push(msg.sender);
        addresses.push(_adr);
    }
    
    function GetHome(string memory adr) public returns (uint _area, uint _cost){
        return (homes[adr].area, homes[adr].cost);
    }
    
    function AddEmployee(address empl, string memory _nameEmployee, string memory _position, string memory _phoneNumber) public OnlyOwner{
        Employee memory e;
        e.nameEmployee = _nameEmployee;
        e.position = _position;
        e.phoneNumber = _phoneNumber;
        e.isset = true;
        employees[empl] = e;
        
    }
    
    function EditEmployee(address empl, string memory _nameEmployee, string memory _position, string memory _phoneNumber) public OnlyOwner{
        employees[empl].nameEmployee = _nameEmployee;
        employees[empl].position = _position;
        employees[empl].phoneNumber = _phoneNumber;
    }
    
    function DeleteEmployee(address empl) public OnlyOwner returns(bool) {
        if(employees[msg.sender].isset == true){
        delete employees[empl];
        return true;
        }
        return false;
    }
    
    function GetEmployee(address empl) public OnlyOwner returns (string memory _nameEmployee, string memory _position, string memory _phoneNumber){
        return (employees[empl].nameEmployee, employees[empl].position, employees[empl].phoneNumber);
    }
    
    function AddRequest(uint rType, string memory _homeAddress, uint _area, uint _cost, address newOwner) public Costs(price) payable returns (bool){
        Request memory r;
        r.requestType = rType ==0? RequestType.NewHome: RequestType.EditHome;
        r.homeAddress = _homeAddress;
        r.area = _area;
        r.cost = _cost;
        r.result = 0;
        r.adr = rType==0?address(0):newOwner;
        r.isProcessed = false;
        requests[msg.sender] = r;
        requestInitiator.push(msg.sender);
        amount += msg.value;
        return true;
    }
    
    function GetRequest() public OnlyEmployee returns (uint[] memory, uint[] memory, string[] memory){
        uint[] memory ids = new uint[](requestInitiator.length);
        uint[] memory types = new uint[](requestInitiator.length);
        string[] memory homeAddresses = new string[](requestInitiator.length);
        for(uint i=0;i!=requestInitiator.length;i++){
            ids[i] = i;
            types[i] = requests[requestInitiator[i]].requestType == RequestType.NewHome ? 0: 1;
            homeAddresses[i] = requests[requestInitiator[i]].homeAddress;
        }
        return (ids, types, homeAddresses);
    }
    
     function GetListHome() public view returns (uint[] memory, uint[] memory, string[] memory)
    {
        uint[] memory costss = new uint[](listHomeInitiator.length);
        uint[] memory areas = new uint[](listHomeInitiator.length);
        string[] memory homeAddresses = new string[](listHomeInitiator.length);
        for(uint i=0;i!=listHomeInitiator.length;i++){
            costss[i] = homess[listHomeInitiator[i]].cost;
            areas[i] = homess[listHomeInitiator[i]].area;
            homeAddresses[i] = homess[listHomeInitiator[i]].homeAddress;
        }
        return (costss, areas, homeAddresses);
    }
    
    function ProcessRequest(uint Id) public OnlyEmployee returns (uint){
        if(Id<0 || Id>=requestInitiator.length) return 1;
        Request memory r = requests[requestInitiator[Id]];
        if(r.requestType == RequestType.NewHome && homes[r.homeAddress].isset){
            delete requests[requestInitiator[Id]];
            delete requestInitiator[Id];
            return 2;
        } 
        if(r.requestType == RequestType.NewHome){
            //add new Home
            AddHome(r.homeAddress, r.area, r.cost);
            //set ownership
            Ownership memory ownership;
            ownership.homeAddress = r.homeAddress;
            ownership.owner = requestInitiator[Id];
            ownership.p = 1;
            ownerships[r.homeAddress].push(ownership);
        } else {
            //edit home
            //change ownership
        }
        delete requests[requestInitiator[Id]];
        delete requestInitiator[Id];
        return 0;
    }
    
    function EditCost(uint _price) public OnlyOwner
    {
        price = _price;
    }
    
    function GetCost() public returns (uint)
    {
        return price;
    }
 
    function AddOwnership(string memory _homeAddr, address _owner, uint _p) public{
        Ownership memory o;
        o.homeAddress = _homeAddr;
        o.owner = _owner;
        o.p = _p;
        ownerships[_homeAddr].push(o);
    }
    
    function DeleteOwnership(string memory _homeAddr, address _owner) public {
        uint len = ownerships[_homeAddr].length;
        uint temp;
        for(uint i=0; i!= ownerships[_homeAddr].length; i++){
            if(ownerships[_homeAddr][i].owner == _owner){
                temp = i;
            }
        }
        if(temp != ownerships[_homeAddr].length - 1){
            ownerships[_homeAddr][temp];
        }
    }
    
    function GetOwnership(string memory _homeAddr) public returns (uint[] memory, address[] memory){
        uint[] memory Op = new uint[](ownerships[_homeAddr].length);
        address[] memory Oowner = new address[](ownerships[_homeAddr].length);
        for(uint i=0; i!= ownerships[_homeAddr].length; i++){
            Op[i] = ownerships[_homeAddr][i].p;
            Oowner[i] = ownerships[_homeAddr][i].owner;
        }
        return (Op, Oowner);
    }
}
