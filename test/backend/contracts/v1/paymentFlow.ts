import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Contract } from '@ethersproject/contracts/lib/index';
import { deployContracts, deployPaymentManager } from './utils';
import { AcccessTypes } from './types';

describe('pay for access flow', function () {
    // arbitrary address to represent content NFT
    const CONTENT_ADDRESS = '0x9FA562675ea0d73519F125AC52Aed6C684f7f2d6';
    // accounts
    let admin, payer;
    // contracts 
    let pm: Contract, pf: Contract, config: Contract;
    
    before(async function () {
        [admin, payer] = await ethers.getSigners();
        pm = await deployPaymentManager(admin.address);
        const contracts = await deployContracts({
            adminSigner: admin,
            paymentManagerContract: pm,
            contentAddress: CONTENT_ADDRESS,
        });
        pf = contracts.paymentFacilitator;
        config = contracts.config;
    });

    it('test deployment', async function () {
        console.log('PaymentManager address: ', pm.address);
        console.log('PaymentFacilitator address: ', pf.address);
        console.log('Config address: ', config.address)
    });
    
    it('test', async function () {
        const res = await config.getAccessNFT(AcccessTypes.MONTHLY_VIEW);
        console.log('output from config call: ', res);
    });

});