pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";

// import "@aragon/apps-token-manager/contracts/TokenManager.sol";
// import "@aragon/apps-voting/contracts/Voting.sol";
//
// import "@aragon/os/contracts/apm/APMNamehash.sol";
//
// import "@aragon/os/contracts/kernel/Kernel.sol";
// import "@aragon/os/contracts/acl/ACL.sol";
//
// import "@aragon/os/contracts/apm/Repo.sol";
// import "@aragon/os/contracts/lib/ens/ENS.sol";
// import "@aragon/os/contracts/lib/ens/PublicResolver.sol";
// import "@aragon/os/contracts/evmscript/IEVMScriptRegistry.sol"; // needed for EVMSCRIPT_REGISTRY_APP_ID
//
// import "@aragon/apps-shared-minime/contracts/MiniMeToken.sol";



import "@aragon/apps-voting/contracts/Voting.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";
import "@aragon/apps-shared-minime/contracts/MiniMeToken.sol";

import "@aragon/os/contracts/acl/ACL.sol";
import "@aragon/os/contracts/apm/Repo.sol";
import "@aragon/os/contracts/apm/APMNamehash.sol";
import "@aragon/os/contracts/kernel/Kernel.sol";
import "@aragon/os/contracts/lib/ens/ENS.sol";
import "@aragon/os/contracts/lib/ens/PublicResolver.sol";
import "@aragon/os/contracts/common/IsContract.sol";


contract BaseTemplate is APMNamehash, IsContract {
    /* Hardcoded constant to save gas
    * bytes32 constant internal AGENT_APP_ID = apmNamehash("agent");                  // agent.aragonpm.eth
    * bytes32 constant internal VAULT_APP_ID = apmNamehash("vault");                  // vault.aragonpm.eth
    * bytes32 constant internal VOTING_APP_ID = apmNamehash("voting");                // voting.aragonpm.eth
    * bytes32 constant internal FINANCE_APP_ID = apmNamehash("finance");              // finance.aragonpm.eth
    * bytes32 constant internal TOKEN_MANAGER_APP_ID = apmNamehash("token-manager");  // token-manager.aragonpm.eth
    */
    bytes32 constant internal VOTING_APP_ID = 0x9fa3927f639745e587912d4b0fea7ef9013bf93fb907d29faeab57417ba6e1d4;
    bytes32 constant internal TOKEN_MANAGER_APP_ID = 0x6b20a3010614eeebf2138ccec99f028a61c811b3b1a3343b6ff635985c75c91f;

    string constant private ERROR_ENS_NOT_CONTRACT = "TEMPLATE_ENS_NOT_CONTRACT";
    string constant private ERROR_DAO_FACTORY_NOT_CONTRACT = "TEMPLATE_DAO_FAC_NOT_CONTRACT";
    string constant private ERROR_ARAGON_ID_NOT_PROVIDED = "TEMPLATE_ARAGON_ID_NOT_PROVIDED";
    string constant private ERROR_ARAGON_ID_NOT_CONTRACT = "TEMPLATE_ARAGON_ID_NOT_CONTRACT";
    string constant private ERROR_MINIME_FACTORY_NOT_PROVIDED = "TEMPLATE_MINIME_FAC_NOT_PROVIDED";
    string constant private ERROR_MINIME_FACTORY_NOT_CONTRACT = "TEMPLATE_MINIME_FAC_NOT_CONTRACT";

    ENS internal ens;
    MiniMeTokenFactory internal miniMeFactory;

    uint64 constant PCT = 10 ** 16;
    address constant ANY_ENTITY = address(-1);

    event DeployToken(address token);
    event InstalledApp(address appProxy, bytes32 appId);


    /* ACL */

    function _createPermissions(ACL _acl, address[] _grantees, address _app, bytes32 _permission, address _manager) internal {
        _acl.createPermission(_grantees[0], _app, _permission, address(this));
        for (uint256 i = 1; i < _grantees.length; i++) {
            _acl.grantPermission(_grantees[i], _app, _permission);
        }
        _acl.revokePermission(address(this), _app, _permission);
        _acl.setPermissionManager(_manager, _app, _permission);
    }

    function _createPermissionForTemplate(ACL _acl, address _app, bytes32 _permission) internal {
        _acl.createPermission(address(this), _app, _permission, address(this));
    }

    function _removePermissionFromTemplate(ACL _acl, address _app, bytes32 _permission) internal {
        _acl.revokePermission(address(this), _app, _permission);
        _acl.removePermissionManager(_app, _permission);
    }

    /* TOKEN MANAGER */

    function _installTokenManagerApp(Kernel _dao, MiniMeToken _token, bool _transferable, uint256 _maxAccountTokens) internal returns (TokenManager) {
        TokenManager tokenManager = TokenManager(_installNonDefaultApp(_dao, TOKEN_MANAGER_APP_ID));
        _token.changeController(tokenManager);
        tokenManager.initialize(_token, _transferable, _maxAccountTokens);
        return tokenManager;
    }

    function _createTokenManagerPermissions(ACL _acl, TokenManager _tokenManager, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _tokenManager, _tokenManager.MINT_ROLE(), _manager);
        _acl.createPermission(_grantee, _tokenManager, _tokenManager.ASSIGN_ROLE(), _manager);
        _acl.createPermission(_grantee, _tokenManager, _tokenManager.REVOKE_VESTINGS_ROLE(), _manager);
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address[] _holders, uint256[] _stakes) internal {
        // _createPermissionForTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
        for (uint256 i = 0; i < _holders.length; i++) {
            _tokenManager.mint(_holders[i], _stakes[i]);
        }
        _removePermissionFromTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address[] _holders, uint256 _stake) internal {
        _createPermissionForTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
        for (uint256 i = 0; i < _holders.length; i++) {
            _tokenManager.mint(_holders[i], _stake);
        }
        _removePermissionFromTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
    }

    function _mintTokens(ACL _acl, TokenManager _tokenManager, address _holder, uint256 _stake) internal {
        // _createPermissionForTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
        _tokenManager.mint(_holder, _stake);
        // _removePermissionFromTemplate(_acl, _tokenManager, _tokenManager.MINT_ROLE());
    }

    /* VOTING */

    function _installVotingApp(Kernel _dao, MiniMeToken _token, uint64 _support, uint64 _acceptance, uint64 _duration) internal returns (Voting) {
        Voting voting = Voting(_installNonDefaultApp(_dao, VOTING_APP_ID));
        voting.initialize(_token, _support, _acceptance, _duration);
        return voting;
    }

    function _createVotingPermissions(ACL _acl, Voting _voting, address _grantee, address _manager) internal {
        _acl.createPermission(_grantee, _voting, _voting.MODIFY_QUORUM_ROLE(), _manager);
        _acl.createPermission(_grantee, _voting, _voting.MODIFY_SUPPORT_ROLE(), _manager);
    }

    /* APPS */

    function _installNonDefaultApp(Kernel _dao, bytes32 _appId) internal returns (address) {
        return _installApp(_dao, _appId, new bytes(0), false);
    }

    function _installDefaultApp(Kernel _dao, bytes32 _appId) internal returns (address) {
        return _installApp(_dao, _appId, new bytes(0), true);
    }

    function _installApp(Kernel _dao, bytes32 _appId, bytes _data, bool _setDefault) internal returns (address) {
        address latestBaseAppAddress = _latestVersionAppBase(_appId);
        address instance = address(_dao.newAppInstance(_appId, latestBaseAppAddress, _data, _setDefault));
        emit InstalledApp(instance, _appId);
        return instance;
    }

    function _latestVersionAppBase(bytes32 _appId) internal view returns (address base) {
        Repo repo = Repo(PublicResolver(ens.resolver(_appId)).addr(_appId));
        (,base,) = repo.getLatest();
    }

    /* TOKEN */

    function _createToken(string _name, string _symbol, uint8 _decimals) internal returns (MiniMeToken) {
        // require(address(miniMeFactory) != address(0), ERROR_MINIME_FACTORY_NOT_PROVIDED);

        MiniMeToken token = miniMeFactory.createCloneToken(MiniMeToken(address(0)), 0, _name, _decimals, _symbol, true);
        emit DeployToken(address(token));
        return token;
    }

    function _ensureMiniMeFactoryIsValid(address _miniMeFactory) internal view {
        require(isContract(address(_miniMeFactory)), ERROR_MINIME_FACTORY_NOT_CONTRACT);
    }
}


contract JournalApp is AragonApp, BaseTemplate {

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

    function initialize(MiniMeTokenFactory _miniMeFactory) public onlyInit {
        initialized();
        ens = ENS(0x5f6f7e8cc7346a11ca2def8f827b7a0b612c56a1);
        miniMeFactory = _miniMeFactory;

    }

    /**
     * @notice Accept for review a paper
     * @param hash IPFS hash for the paper
     */
    function acceptForReview(bytes hash) external auth(ACCEPT_FOR_REVIEW_ROLE) {
        assert(lastPaper + 1 >= lastPaper);
        lastPaper = lastPaper + 1;
        papersState[lastPaper] = 0;
        addEditorsCommittee();
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

    function addEditorsCommittee() internal {
        Kernel _dao = Kernel(kernel());
        ACL acl = ACL(_dao.acl());
        MiniMeToken token = _createToken("Reviewers", "RVW", 0);
        TokenManager tokenManager = _installTokenManagerApp(_dao, token, false, 1);
        _createTokenManagerPermissions(acl, tokenManager, this, this);
        _mintTokens(acl, tokenManager, msg.sender, 1);
        Voting voting = _installVotingApp(_dao, token, 50 * PCT, 20 * PCT, 1 days);
        _createVotingPermissions(acl, voting, this, this);
    }
}
