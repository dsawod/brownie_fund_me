from brownie import FundMe, network, config, MockV3Aggregator
from scripts.helpful_scripts import deploy_mocks, get_account, LOCAL_BLOCKCHAIN_ENV
from web3 import Web3


def deploy_fund_me():
    account = get_account()
    # Pass the priceFeed address
    # If we are on network like rinkeby, use the associated address
    # Otherwise, deploy mocks

    if network.show_active() not in LOCAL_BLOCKCHAIN_ENV:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]

    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address
        print("Mocks Deployed!")

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )

    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
