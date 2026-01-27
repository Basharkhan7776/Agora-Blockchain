// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from 'forge-std/Test.sol';
import {ElectionFactory} from '../contracts/ElectionFactory.sol';
import {Election} from '../contracts/Election.sol';

contract ElectionFactoryTest is Test {
  ElectionFactory public factory;
  address public owner;
  address public user1;
  address public user2;
  address public router; // Mock router

  Election.ElectionInfo public mockElectionInfo;
  Election.Candidate[] public mockCandidates;

  function setUp() public {
    owner = address(this);
    user1 = makeAddr('user1');
    user2 = makeAddr('user2');
    router = makeAddr('router');

    factory = new ElectionFactory(router);

    mockElectionInfo = Election.ElectionInfo({
      name: 'Test Election',
      description: 'Test Description',
      startTime: block.timestamp + 3600,
      endTime: block.timestamp + 7200
    });

    // Initialize mockCandidates
    mockCandidates.push(
      Election.Candidate({
        candidateID: 0,
        name: 'Option 1',
        description: 'Desc 1'
      })
    );
    mockCandidates.push(
      Election.Candidate({
        candidateID: 1,
        name: 'Option 2',
        description: 'Desc 2'
      })
    );
    mockCandidates.push(
      Election.Candidate({
        candidateID: 2,
        name: 'Option 3',
        description: 'Desc 3'
      })
    );
  }

  function test_OwnerIsSet() public view {
    assertEq(factory.factoryOwner(), owner);
  }

  function test_InitializeWithZeroElections() public view {
    assertEq(factory.electionCount(), 0);
    assertEq(factory.getOpenElections().length, 0);
  }

  function test_CreateElection() public {
    factory.createElection(mockElectionInfo, mockCandidates, 0, 0);
    assertEq(factory.electionCount(), 1);

    address[] memory openElections = factory.getOpenElections();
    assertEq(openElections.length, 1);
  }

  function test_CreateMultipleElections() public {
    factory.createElection(mockElectionInfo, mockCandidates, 0, 0);
    factory.createElection(mockElectionInfo, mockCandidates, 0, 0);

    assertEq(factory.electionCount(), 2);
    assertEq(factory.getOpenElections().length, 2);
  }

  function test_DeleteElection() public {
    factory.createElection(mockElectionInfo, mockCandidates, 0, 0); // ID 0
    assertEq(factory.getOpenElections().length, 1);

    factory.deleteElection(0);
    assertEq(factory.getOpenElections().length, 0);
  }

  function test_RevertIf_DeleteElection_NotOwner() public {
    factory.createElection(mockElectionInfo, mockCandidates, 0, 0);

    vm.prank(user1);
    vm.expectRevert(ElectionFactory.OnlyOwner.selector);
    factory.deleteElection(0);
  }

  function test_WhitelistedContractsManagement() public {
    uint64 sourceChainSelector = 1;
    address contractAddress = makeAddr('contract');

    // Add
    factory.addWhitelistedContract(sourceChainSelector, contractAddress);
    // We can't easily check the mapping without a getter or checking 'approvedSenderContracts' if it was public (it is private)
    // But we can check if it reverts on unauthorized access if we had a way to trigger it.
    // However, we just want to ensure it doesn't revert for owner.

    // Remove contract
    factory.removeWhitelistedContract(sourceChainSelector);
  }

  function test_RevertIf_AddWhitelistedContract_NotOwner() public {
    uint64 sourceChainSelector = 1;
    address contractAddress = makeAddr('contract');

    vm.prank(user1);
    vm.expectRevert(ElectionFactory.OwnerRestricted.selector);
    factory.addWhitelistedContract(sourceChainSelector, contractAddress);
  }
}
