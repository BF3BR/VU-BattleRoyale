import React from 'react';
import { getItemType } from '../helpers/InventoryHelper';

import "./LootOverlay.scss";

interface Props {
    loot: any;
}

const LootOverlay: React.FC<Props> = ({ loot }) => {
    return (
        <div className="lootOverlay">
            <div className={"tier " + (loot.Tier !== undefined ? "tier-" + loot.Tier : "tier-1")}>
                {loot.UIIcon &&
                    <div className="image">
                        {loot.UIIcon.startsWith("__") ?
                            <img src={"/img/" + loot.UIIcon + ".png"} alt="" />
                        :
                            <img src={"fb://" + loot.UIIcon} alt="" />
                        }
                    </div>
                }
                {/*loot === "Basic" &&
                    <div className="image">
                        <img src="fb://UI/Art/Persistence/Award/Ribbons/Fancy/gunmaster3d" alt="" />
                    </div>
                */}

                <div className="information">
                    {loot.Name &&
                        <span className="name">{loot.Name ?? ""}</span>
                    }
                    {/*loot.Quantity > 1 &&
                        <span className="count">{loot.Quantity ?? 1}</span>
                    */}
                    {loot.Type &&
                        <span className="ammoType">
                            {getItemType(loot.Type)}
                        </span>
                    }
                    {/*(loot.CurrentDurability !== undefined && loot.Durability !== undefined) &&
                        <div className="progressWrapper">
                            <div className="progressWrapperBg">
                                <div className="progressWrapperFg" style={{ height: (loot.CurrentDurability / loot.Durability * 100) + "%" }}></div>
                            </div>
                        </div>
                    */}
                    {loot.Tier !== undefined &&
                        <span className="tier">
                            {loot.Tier === 1 &&
                                <img src="fb://UI/Art/Persistence/Ranks/Rank001" alt="" />
                            }
                            {loot.Tier === 2 &&
                                <img src="fb://UI/Art/Persistence/Ranks/Rank002" alt="" />
                            }
                            {loot.Tier === 3 &&
                                <img src="fb://UI/Art/Persistence/Ranks/Rank003" alt="" />
                            }
                        </span>
                    }

                    {loot === "Basic" &&
                        <span className="name">Backpack</span>
                    }
                </div>
            </div>
            <div className="keyinfo">
                <h4>Press E to pickup</h4>
            </div>
        </div>
    )
};

export default React.memo(LootOverlay);
