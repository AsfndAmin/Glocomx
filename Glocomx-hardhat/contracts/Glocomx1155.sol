// SPDX-License-Identifier: unlicense
pragma solidity ^0.8.9;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Glocomx is ERC1155, AccessControl {
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    
    struct TokenData{
        uint256 maxSupply;
        uint256 mintPrice;
    }

    mapping(uint256 => TokenData) public _tokens;
    mapping(uint256 => uint256) private _totalSupply;
    address ownerAddress;
    address public paymentToken;
    uint256 public tokenNumber;
    uint256[] public tokenNum;

    event TokenDataEvent(uint256[] id, uint256[] supply, uint256[] price);

    constructor(address _ownerAddress, address _paymentToken, uint256[] memory _supply, uint256[] memory _price, string memory _name) ERC1155(_name) {   
        require(_ownerAddress != address(0), "address cant be 0");
        require(_price.length == _supply.length, "parameters not same");

        _grantRole(DEFAULT_ADMIN_ROLE, _ownerAddress);
        _grantRole(OWNER_ROLE, _ownerAddress);

        ownerAddress = _ownerAddress;
        paymentToken = _paymentToken;
        for (uint i = 0; i < _supply.length; i++) { 
            tokenNumber++;
            _tokens[tokenNumber] = TokenData({
            maxSupply : _supply[i],
            mintPrice : _price[i] 
            });
            tokenNum.push(tokenNumber);
        } 
        emit TokenDataEvent(tokenNum, _supply, _price);
        delete tokenNum;
    }      
      
    function mint(address account, uint256 id, uint256 amount) 
        external
    {
        require(id <= tokenNumber, "Invalid id");
        require(_totalSupply[id] + amount <= _tokens[id].maxSupply, "maxSupply Reched");

        uint256 price = _tokens[id].mintPrice * amount;
        IERC20(paymentToken).transferFrom(msg.sender, ownerAddress, price);
        _mint(account, id, amount, "");
        _totalSupply[id] += amount;
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts)
        external
    {
        uint256 totalPrice;
        for (uint i = 0; i < ids.length; i++) {
        require(ids[i] <= tokenNumber, "Invalid id");
            require(_totalSupply[ids[i]] + amounts[i] <= _tokens[ids[i]].maxSupply, "maxSupply Reached"); 

            totalPrice += (_tokens[ids[i]].mintPrice * amounts[i]);
            _totalSupply[ids[i]] += amounts[i];
        }
        IERC20(paymentToken).transferFrom(msg.sender, ownerAddress, totalPrice);
        _mintBatch(to, ids, amounts, "");
    }

    function updateTokenData(uint256[] memory _supply, uint256[] memory _price, uint256[] memory _id) external onlyRole(OWNER_ROLE) {
        require(_supply.length == _price.length && _supply.length == _id.length, "length mismatch");
        for (uint i = 0; i < _supply.length; i++) {
        require(_price[i] !=0, "can't be 0");
        require(_tokens[_id[i]].maxSupply != 0 && _supply[i] > _tokens[_id[i]].maxSupply , "invalid supply set"); 
        require(_id[i] <= tokenNumber, "Invalid id");
            _tokens[_id[i]] = TokenData({
                 maxSupply : _supply[i],
                 mintPrice : _price[i]
             });
        }
             emit TokenDataEvent(_id, _supply, _price);
    }

    function setTokenData(uint256[] memory _supply, uint256[] memory _price)external onlyRole(OWNER_ROLE) {
        require(_supply.length == _price.length, "length mismatch");
        for (uint i = 0; i < _supply.length; i++) {
        require(_price[i] !=0 && _supply[i] !=0, "cant be 0");
        tokenNumber++; 
        _tokens[tokenNumber] = TokenData({
            maxSupply : _supply[i],
            mintPrice : _price[i]
        });
        tokenNum.push(tokenNumber);
        }
        emit TokenDataEvent(tokenNum, _supply, _price);   
        delete tokenNum;  
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
