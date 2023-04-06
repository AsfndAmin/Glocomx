// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Glocomx1155.sol";

contract GlocomoxFactory is AccessControl,  ReentrancyGuard {

    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    event contractDeployed(address, address);

    address platformAddress;

    constructor(address _platformAddress) {
        platformAddress = _platformAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEPLOYER_ROLE, _platformAddress);
    }

     function deployPool(
         address _ownerAddress,
         address _paymentToken,
         uint256[] memory _supply,
         uint256[] memory _price,
         string memory _name
         )
          external 
          nonReentrant
          onlyRole(DEPLOYER_ROLE)  { 

    Glocomx  newGlocomx = new Glocomx(
                _ownerAddress,
                _paymentToken,
                _supply, 
                _price,
                _name

            );

        emit contractDeployed(address(newGlocomx), _ownerAddress);

}

}
