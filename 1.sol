pragma solidity ^0.8.0;

import "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol";

contract BirthdayPayout {

    string _name;

    address _owner;

    Teammate[] public _teammates;

    struct Teammate {
        string name;
        address account;
        uint256 birthday;
        uint256 last_payout;
    }

    uint256 constant PRESENT = 100000000000000000;

    constructor() public {
        _name="max";
        _owner = msg.sender;
    }

    function addTeammate(address account,string memory name, uint256 birthday) public onlyOwner {
        require(msg.sender != account,"Cannot add oneself");
        Teammate memory newTeammate = Teammate(name,account, birthday,0); 
        _teammates.push(newTeammate);
        emit NewTeammate(account,name);
    }

    function findBirthday() public onlyOwner{
        require(getTeammatesNumber()>0,"No teammates in the database");
        for(uint256 i=0;i<getTeammatesNumber();i++){
            if(checkBirthday(i) && checkLastPayout(i)){
                birthdayPayout(i);               
            }
        }
    }

    function birthdayPayout(uint256 index) public onlyOwner {
        require(address(this).balance>=PRESENT,"Not enough balance");
        setLastPayout(index);
        sendToTeammate(index);
        emit HappyBirthday(_teammates[index].name,_teammates[index].account);
    }

    function setLastPayout(uint256 index) public{
        _teammates[index].last_payout=block.timestamp;
    }

    function getDate(uint256 timestamp) view public returns(uint256 year, uint256 month, uint256 day){
        (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
    }

    function checkBirthday(uint256 index) view public returns(bool){
        uint256 birthday = getTeammate(index).birthday;
        (, uint256 birthday_month,uint256 birthday_day) = getDate(birthday);
        uint256 today = block.timestamp;
        (, uint256 today_month,uint256 today_day) = getDate(today);

        if(birthday_day == today_day && birthday_month==today_month){
            return true;
        }
        return false;
    }

function checkLastPayout(uint256 index) view public returns(bool){
        uint256 last_payout = getTeammate(index).last_payout;
        (uint256 last_payout_year, uint256 last_payout_month,uint256 last_payout_day) = getDate(last_payout);
        uint256 today = block.timestamp;
        (uint256 today_year, uint256 today_month,uint256 today_day) = getDate(today);

        if(last_payout_day == today_day && last_payout_month==today_month && last_payout_year==today_year){
            return false;
        }
        return true;
    }

    function getTeammate(uint256 index) view public returns(Teammate memory){
        return _teammates[index];
    }

    function getTeam() view public returns(Teammate[] memory){
        return  _teammates;
    }

    function getTeammatesNumber() view public returns(uint256){
        return _teammates.length;
    }

    function sendToTeammate(uint256 index) public onlyOwner{
        payable(_teammates[index].account).transfer(PRESENT);
    }

    function deposit() public payable{

    }

    modifier onlyOwner{
        require(msg.sender == _owner,"Sender should be the owner of contract");
        _;
    }

    event NewTeammate(address account, string name);

    event HappyBirthday(string name, address account);
}
