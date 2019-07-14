pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";


contract JournalApp is AragonApp {

    /// Events
    event AcceptForReview(address indexed entity, uint256 paper, bytes hash);
    event Publish(address indexed entity, uint256 paper);
    event Unpublish(address indexed entity, uint256 paper);

    /// State
    uint256 public lastPaper;
    mapping(uint256 => int8) public papersState; // 0 -> preprint, 1 -> published, -1 -> revoked

    /// ACL
    bytes32 constant public ACCEPT_FOR_REVIEW_ROLE = keccak256("ACCEPT_FOR_REVIEW_ROLE");
    bytes32 constant public PUBLISH_ROLE = keccak256("PUBLISH_ROLE");
    bytes32 constant public UNPUBLISH_ROLE = keccak256("UNPUBLISH_ROLE");

    function initialize() public onlyInit {
        initialized();
    }

    /**
     * @notice Accept for review a paper
     * @param hash IPFS hash for the paper
     */
    function acceptForReview(bytes hash) external auth(ACCEPT_FOR_REVIEW_ROLE) {
        assert(lastPaper + 1 >= lastPaper);
        lastPaper = lastPaper + 1;
        papersState[lastPaper] = 0;
        emit AcceptForReview(msg.sender, lastPaper, hash);
    }

    /**
     * @notice Publish the paper #`paper`
     * @param paper Number of the paper to publish
     */
    function publish(uint256 paper) external auth(PUBLISH_ROLE) {
        papersState[paper] = 1;
        emit Publish(msg.sender, paper);
    }

    /**
     * @notice Unpublish the paper #`paper`
     * @param paper Number of the paper to unpublish
     */
    function unpublish(uint256 paper) external auth(UNPUBLISH_ROLE) {
        papersState[paper] = -1;
        emit Unpublish(msg.sender, paper);
    }
}
