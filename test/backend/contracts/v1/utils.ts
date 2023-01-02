import { ethers } from 'hardhat';
import { Contract } from '@ethersproject/contracts/lib/index';
import { AcccessTypes } from './types';

export const deployPaymentManager = async (adminAddress: string): Promise<Contract> => {
    return await deployGenericContract('PaymentManager', [adminAddress]);
}

export const deployContracts = async ({ adminSigner, paymentManagerContract, contentAddress }: Record<string, any>): Promise<Record<string, Contract>> => {

    // deploy config contract
    const config = await deployGenericContract('ContentConfig', [adminSigner.address]);
    
    // deploy Owners
    const owners = await deployGenericContract('Owners', [config.address]);
    
    // deploy Access NFT(s)
    const accessHourly = await deployGenericContract('Access', [AcccessTypes.HOURLY_VIEW, config.address, '']);
    
    // deploy PaymentFacilitator
    const paymentFacilitator = await deployGenericContract('PaymentFacilitator', [config.address, paymentManagerContract.address]);

    // init config contract
    await config
        .connect(adminSigner)
        .__ContentConfig__init(
            [AcccessTypes.HOURLY_VIEW],
            [accessHourly.address],
            paymentFacilitator.address,
            owners.address,
            contentAddress,
        );

    // set payment facilitator on PM
    await paymentManagerContract
        .connect(adminSigner)
        .setFacilitator(paymentFacilitator.address, true);

    return { paymentFacilitator, config };
}

const deployGenericContract = async (contractName: string, args: any[]): Promise<Contract> => {
    const Contract = await ethers.getContractFactory(contractName);
    const contract = await Contract.deploy(...args);
    await contract.deployed();
    return contract;
}