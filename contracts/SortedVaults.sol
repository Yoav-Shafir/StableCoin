//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Base.sol";
import "./Borrowing.sol";
import "./VaultManager.sol";

contract SortedVaults is Base {
    Borrowing borrowing;
    VaultManager vaultManager;

    // Information for a node in the list
    struct Node {
        bool exists;
        address nextId; // Id of next node (smaller NICR) in the list
        address prevId; // Id of previous node (larger NICR) in the list
    }

    // Information for the list
    struct Data {
        address head; // Head of the list. Also the node in the list with the largest NICR
        address tail; // Tail of the list. Also the node in the list with the smallest NICR
        uint256 maxSize; // Maximum size of the list
        uint256 size; // Current size of the list
        mapping(address => Node) nodes; // Track the corresponding ids for each node in the list
    }

    Data public data;

    constructor() {
        data.maxSize = 10;
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);

        (address _borrowing, ) = getContractInfo("Borrowing");
        borrowing = Borrowing(_borrowing);

        (address _vaultManager, ) = getContractInfo("VaultManager");
        vaultManager = VaultManager(_vaultManager);
    }

    /*
     * @dev Add a node to the list
     * @param _id Node's id
     * @param _NICR Node's NICR
     */

    function insert(address _id, uint256 _NICR)
        external
        onlyBorrowingOrVaultManager
    {
        _insert(_id, _NICR);
    }

    function _insert(address _id, uint256 _NICR) internal {
        // List must not be full
        require(!isFull(), "SortedVaults: List is full");

        // List must not already contain node
        require(!contains(_id), "SortedVaults: List already contains the node");

        // Node id must not be null
        require(_id != address(0), "SortedVaults: Id cannot be zero");

        // NICR must be non-zero
        require(_NICR > 0, "SortedVaults: NICR must be positive");

        address prevId;
        address nextId;

        (prevId, nextId) = _findInsertPosition(_NICR);

        data.nodes[_id].exists = true;

        if (prevId == address(0) && nextId == address(0)) {
            // Insert as head and tail
            data.head = _id;
            data.tail = _id;
        } else if (prevId == address(0)) {
            // Insert before `prevId` as the head
            data.nodes[_id].nextId = data.head;
            data.nodes[data.head].prevId = _id;
            data.head = _id;
        } else if (nextId == address(0)) {
            // Insert after `nextId` as the tail
            data.nodes[_id].prevId = data.tail;
            data.nodes[data.tail].nextId = _id;
            data.tail = _id;
        } else {
            // Insert at insert position between `prevId` and `nextId`
            data.nodes[_id].nextId = nextId;
            data.nodes[_id].prevId = prevId;
            data.nodes[prevId].nextId = _id;
            data.nodes[nextId].prevId = _id;
        }

        data.size = data.size + 1;
    }

    function remove(address _id) external onlyVaultManager {
        _remove(_id);
    }

    /*
     * @dev Remove a node from the list
     * @param _id Node's id
     */
    function _remove(address _id) internal {
        // List must contain the node
        require(contains(_id), "SortedTroves: List does not contain the id");

        if (data.size > 1) {
            // List contains more than a single node
            if (_id == data.head) {
                // The removed node is the head
                // Set head to next node
                data.head = data.nodes[_id].nextId;
                // Set prev pointer of new head to null
                data.nodes[data.head].prevId = address(0);
            } else if (_id == data.tail) {
                // The removed node is the tail
                // Set tail to previous node
                data.tail = data.nodes[_id].prevId;
                // Set next pointer of new tail to null
                data.nodes[data.tail].nextId = address(0);
            } else {
                // The removed node is neither the head nor the tail
                // Set next pointer of previous node to the next node
                data.nodes[data.nodes[_id].prevId].nextId = data
                    .nodes[_id]
                    .nextId;
                // Set prev pointer of next node to the previous node
                data.nodes[data.nodes[_id].nextId].prevId = data
                    .nodes[_id]
                    .prevId;
            }
        } else {
            // List contains a single node
            // Set the head and tail to null
            data.head = address(0);
            data.tail = address(0);
        }

        delete data.nodes[_id];
        data.size = data.size - 1;
    }

    /*
     * @dev Re-insert the node at a new position, based on its new NICR
     * @param _id Node's id
     * @param _newNICR Node's new NICR
     */
    function reInsert(address _id, uint256 _newNICR)
        external
        onlyBorrowingOrVaultManager
    {
        // List must contain the node
        require(contains(_id), "SortesVaults: List does not contain the id");
        // NICR must be non-zero
        require(_newNICR > 0, "SortesVaults: NICR must be positive");

        // Remove node from the list
        _remove(_id);

        _insert(_id, _newNICR);
    }

    /*
     * @dev Checks if the list contains a node
     */
    function contains(address _id) public view returns (bool) {
        return data.nodes[_id].exists;
    }

    /*
     * @dev Checks if the list is full
     */
    function isFull() public view returns (bool) {
        return data.size == data.maxSize;
    }

    /*
     * @dev Checks if the list is empty
     */
    function isEmpty() public view returns (bool) {
        return data.size == 0;
    }

    /*
     * @dev Returns the current size of the list
     */
    function getSize() external view returns (uint256) {
        return data.size;
    }

    /*
     * @dev Returns the maximum size of the list
     */
    function getMaxSize() external view returns (uint256) {
        return data.maxSize;
    }

    /*
     * @dev Returns the first node in the list (node with the largest NICR)
     */
    function getFirst() external view returns (address) {
        return data.head;
    }

    /*
     * @dev Returns the last node in the list (node with the smallest NICR)
     */
    function getLast() external view returns (address) {
        return data.tail;
    }

    /*
     * @dev Returns the next node (with a smaller NICR) in the list for a given node
     * @param _id Node's id
     */
    function getNext(address _id) external view returns (address) {
        return data.nodes[_id].nextId;
    }

    /*
     * @dev Returns the previous node (with a larger NICR) in the list for a given node
     * @param _id Node's id
     */
    function getPrev(address _id) external view returns (address) {
        return data.nodes[_id].prevId;
    }

    function _validInsertPosition(
        uint256 _NICR,
        address _prevId,
        address _nextId
    ) internal view returns (bool) {
        if (_prevId == address(0) && _nextId == address(0)) {
            // `(null, null)` is a valid insert position if the list is empty
            return isEmpty();
        } else if (_prevId == address(0)) {
            // `(null, _nextId)` is a valid insert position if `_nextId` is the head of the list
            return true;
            // return
            //     data.head == _nextId &&
            //     _NICR >= vaultManager.getNominalICR(_nextId);
        } else if (_nextId == address(0)) {
            // `(_prevId, null)` is a valid insert position if `_prevId` is the tail of the list
            return true;
            // return
            //     data.tail == _prevId &&
            //     _NICR <= vaultManager.getNominalICR(_prevId);
        } else {
            // `(_prevId, _nextId)` is a valid insert position if they are adjacent nodes and `_NICR` falls between the two nodes' NICRs
            return true;
            // return
            //     data.nodes[_prevId].nextId == _nextId &&
            //     vaultManager.getNominalICR(_prevId) >= _NICR &&
            //     _NICR >= vaultManager.getNominalICR(_nextId);
        }
    }

    /*
     * @dev Descend the list (larger NICRs to smaller NICRs) to find a valid insert position
     * @param _NICR Node's NICR
     * @param _startId Id of node to start descending the list from
     */
    function _descendList(uint256 _NICR, address _startId)
        internal
        view
        returns (address, address)
    {
        // If `_startId` is the head, check if the insert position is before the head
        if (
            true
            // data.head == _startId &&
            // _NICR >= vaultManager.getNominalICR(_startId)
        ) {
            return (address(0), _startId);
        }

        address prevId = _startId;
        address nextId = data.nodes[prevId].nextId;

        // Descend the list until we reach the end or until we find a valid insert position
        while (
            prevId != address(0) && !_validInsertPosition(_NICR, prevId, nextId)
        ) {
            prevId = data.nodes[prevId].nextId;
            nextId = data.nodes[prevId].nextId;
        }

        return (prevId, nextId);
    }

    /*
     * @dev Find the insert position for a new node with the given NICR
     * @param _NICR Node's NICR
     */
    function findInsertPosition(uint256 _NICR)
        external
        view
        returns (address, address)
    {
        return _findInsertPosition(_NICR);
    }

    function _findInsertPosition(uint256 _NICR)
        internal
        view
        returns (address, address)
    {
        return _descendList(_NICR, data.head);
    }

    // modifiers
    modifier onlyVaultManager() {
        require(
            msg.sender == address(vaultManager),
            "SortedVaults: Caller is not the VaultManager"
        );
        _;
    }

    modifier onlyBorrowingOrVaultManager() {
        require(
            msg.sender == address(borrowing) ||
                msg.sender == address(vaultManager),
            "SortedVaults: Caller is neither Borrowing nor VaultManager"
        );
        _;
    }
}
