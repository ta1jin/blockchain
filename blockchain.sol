pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract Owned {
    address private owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier Onlyowner{
        require(
            msg.sender == owner, 
            'lya ti krisa'
            );
        _;
    }
    
    function ChangeOwner(address newOwner) public Onlyowner {
        owner = newOwner;
    }
    
    function GetOwner() public returns (address){
        return owner;
    }
}

contract ROSReestr is Owned
{
    enum RequestType{NewHome, EditHome}
    //enum Position{}
    
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
        RequestType requestType;
        Home home;
        uint result;
        address adr;
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
    mapping(uint => address) private reqCase;
    
    uint countID = 0;
    
    modifier OnlyEmployee {
        require(
            employees[msg.sender].isset != false,
            'krisa obnarujena'
            );
        _;
    }
    
    Employee e;
    
    function AddHome(string memory _adr, uint _area, uint _cost) public {
        Home memory h;
        h.homeAddress = _adr;
        h.area = _area;
        h.cost = _cost;
        homes[_adr] = h;
    }
    
    function GetHome(string memory adr) public returns (uint _area, uint _cost){
        return (homes[adr].area, homes[adr].cost);
    }
    
    function AddEmployee(address empl, string memory _name, string memory _position, string memory _phoneNumber) public Onlyowner {
        e.nameEmployee = _name;
        e.position = _position;
        e.phoneNumber = _phoneNumber;
        employees[empl] = e;
        e.isset = true;
    }
    
    function GetEmployee(address empl) public OnlyEmployee Onlyowner returns (string memory nameEmployee, string memory _position, string memory _phoneNumber) {
        return (employees[empl].nameEmployee, employees[empl].position, employees[empl].phoneNumber);
    }
    
    function EditEmployee(address empl, string memory _newname, string memory _newposition, string memory _newphoneNumber) public OnlyEmployee Onlyowner {
        employees[empl].nameEmployee = _newname;
        employees[empl].position = _newposition;
        employees[empl].phoneNumber = _newphoneNumber;
    }
    
    function DeleteEmployee(address empl) public Onlyowner {
        delete employees[empl];
    }
    
    function AddRequestHome(address empl, string memory _homeAddress, uint _area, uint _cost) public {
        Request memory r;
        Home memory h;
        h.homeAddress = _homeAddress;
        h.area = _area;
        h.cost = _cost;
        r.requestType = RequestType.NewHome;
        r.home = h;
        r.result = 1;
        requests[empl] = r;
        reqCase[countID] = empl;
        countID++;
    }
    
    function GetRequests() public returns (string[] memory reqType, string[] memory Address, uint256[] memory Area, uint256[] memory Cost){
        string[] memory reqType = new string[](countID);
        string[] memory Address = new string[](countID);
        uint[] memory Cost = new uint[](countID);
        uint[] memory Area = new uint[](countID);
        for (uint i = 0; i < countID; i++) 
        {
            reqType[i] = requests[reqCase[i]].requestType == RequestType.NewHome ? "NewHome" : "EditHome";
            Address[i] = requests[reqCase[i]].home.homeAddress;
            Cost[i] = requests[reqCase[i]].home.cost;
            Area[i] = requests[reqCase[i]].home.area;
        }
        return (reqType, Address, Cost, Area);
    }
}
