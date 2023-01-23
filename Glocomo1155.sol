// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyToken is ERC1155, AccessControl {
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

        // Mapping from paymentIndex -> address of payment token
    mapping(uint16 => address) private paymentToken;
    mapping(uint256 => TokenData) public _tokens;
    mapping(uint256 => uint256) private _totalSupply;
    //tokenid that will be created if owner call create token
    uint256 public tokenNumber;

    struct TokenData{
         uint256 maxSupply;
         uint256 mintPrice;
   }
    constructor(address usersAddress, uint256[] memory _supply, uint256[] memory _price) ERC1155("") {   
       
        require(usersAddress != address(0), "user address cant be 0");
        require(_price.length == _supply.length, "parameters not same");
         _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, usersAddress);

         for (uint i = 0; i < _supply.length; i++) { 
             _tokens[tokenNumber] = TokenData({
                 maxSupply : _supply[i],
                 mintPrice : _price[i]
             });
             tokenNumber++; 
         } 
    }      
       
    function mint(address account, uint256 id, uint256 amount, uint16 paymentIndx) 
        public
        
    {
        require(_tokens[id].maxSupply != 0, "not available"); 
        require(_totalSupply[id] + amount <= _tokens[id].maxSupply, "maxSupply Reched");
        uint256 price = _tokens[id].mintPrice*amount;
        IERC20(paymentToken[paymentIndx]).transferFrom( msg.sender, address(this), price);
        _mint(account, id, amount, "");
        _totalSupply[id] += amount;
    }

   


        // Allow only owner to add a payment token at given index 
    function setPaymentToken(uint8 index, address _paymentToken) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(index != 0,"Glocomx: index should not be 0");
        paymentToken[index] = _paymentToken;
    }

    
    // Allows users to get address of payment token on index
    function getPaymentToken(uint16 _index) external view returns(address) {
        return paymentToken[_index];
    }

    function setTokenData(uint256 _supply, uint256 _price, uint256 _id) external onlyRole(OWNER_ROLE) {
        require(_price !=0 && _supply !=0, "cant be 0");
        require(_tokens[_id].maxSupply != 0, "not available"); 
            _tokens[_id] = TokenData({
                 maxSupply : _supply,
                 mintPrice : _price
             });
    }

    function createToken(uint256 _supply, uint256 _price)external onlyRole(OWNER_ROLE) {
        require(_price !=0 && _supply !=0, "cant be 0");
          _tokens[tokenNumber] = TokenData({
                 maxSupply : _supply,
                 mintPrice : _price
             });
             tokenNumber++; 
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
