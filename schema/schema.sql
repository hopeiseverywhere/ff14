DROP SCHEMA IF EXISTS test;
CREATE SCHEMA test;
use test;
-- Creating the Player table
CREATE TABLE Player (
    email VARCHAR(255) PRIMARY KEY,
    playerName VARCHAR(100) NOT NULL,
    isActive BOOLEAN NOT NULL
);
-- Creating the Chara table with foreign key to Player
CREATE TABLE Chara (
    characterID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    playerEmail VARCHAR(255),
    HP INT NOT NULL,
    MP INT NOT NULL,
    UNIQUE (firstName, lastName),
    FOREIGN KEY (playerEmail) REFERENCES Player (email) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- Creating the Job table
CREATE TABLE Job (
    jobID INT AUTO_INCREMENT PRIMARY KEY,
    description TEXT NOT NULL,
    jobName VARCHAR(100) NOT NULL,
    jobCategory VARCHAR(100) NOT NULL
);
-- Creating the CharacterJob table
CREATE TABLE CharacterJob (
    jobID INT,
    characterID INT,
    jobLevel INT NOT NULL CHECK (jobLevel >= 0),
    experience INT NOT NULL CHECK (experience >= 0),
    PRIMARY KEY (jobID, characterID),
    FOREIGN KEY (jobID) REFERENCES Job (jobID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (characterID) REFERENCES Chara (characterID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- Creating the Currencies table
CREATE TABLE Currencies (
    currencyID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    maxCap INT,
    weeklyCap INT,
    lastResetTime DATETIME NOT NULL
);
-- Creating the CharacterCurrency table
CREATE TABLE CharacterCurrency (
    characterID INT,
    currencyID INT,
    totalAmount INT NOT NULL,
    weeklyEarned INT NOT NULL,
    PRIMARY KEY (characterID, currencyID),
    FOREIGN KEY (characterID) REFERENCES Chara (characterID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (currencyID) REFERENCES Currencies (currencyID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- Creating the EquipmentSlot table

CREATE TABLE EquipmentSlot (
    equipSlotID INT PRIMARY KEY,
    slotName VARCHAR(100) NOT NULL UNIQUE,
    -- slotType ENUM('weapon', 'gear') NOT NULL,
    CONSTRAINT chk_equipSlotID_range CHECK (
        equipSlotID BETWEEN 1 AND 10
    )
);
-- Creating the Item table
CREATE TABLE Item (
    itemID INT AUTO_INCREMENT PRIMARY KEY,
    itemName VARCHAR(100) NOT NULL,
    maxStackSize INT CHECK (maxStackSize > 0),
    isSellable BOOLEAN NOT NULL,
    vendorPrice INT,
    itemLevel INT NOT NULL
);
-- Creating the Equipment table
CREATE TABLE Equipment (
    equipmentID INT PRIMARY KEY,
    requiredLevel INT NOT NULL,
    -- equipmentType ENUM('weapon', 'gear') NOT NULL,
    FOREIGN KEY (equipmentID) REFERENCES Item (itemID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- Creating the Gears table as a subtype of Equipment
CREATE TABLE Gears (
    gearID INT PRIMARY KEY,
    equipSlotID INT NOT NULL,
    defenseRating INT,
    magicDefenseRating INT,
    -- equipmentType ENUM('gear') NOT NULL DEFAULT 'gear',
    FOREIGN KEY (gearID) REFERENCES Equipment (equipmentID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (equipSlotID) REFERENCES EquipmentSlot (equipSlotID)
);
-- Creating the Weapons table as a subtype of Equipment
CREATE TABLE Weapons (
    weaponID INT PRIMARY KEY,
    equipSlotID INT DEFAULT 1,
    damageDone INT,
    autoAttack BOOLEAN,
    attackDelay INT,
    -- equipmentType ENUM('weapon') NOT NULL DEFAULT 'weapon',
    FOREIGN KEY (weaponID) REFERENCES Equipment (equipmentID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (equipSlotID) REFERENCES EquipmentSlot (equipSlotID)
);
-- Creating the AttributeType table
CREATE TABLE AttributeType (
    attributeTypeID INT AUTO_INCREMENT PRIMARY KEY,
    attributeName VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);
-- Creating the CharacterAttribute table
CREATE TABLE CharacterAttribute (
    characterID INT,
    attributeTypeID INT,
    value INT NOT NULL,
    PRIMARY KEY (characterID, attributeTypeID),
    FOREIGN KEY (characterID) REFERENCES Chara (characterID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (attributeTypeID) REFERENCES AttributeType (attributeTypeID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- Creating the ItemBonus table
CREATE TABLE ItemBonus (
    itemID INT,
    attributeTypeID INT,
    bonusVal INT,
    foodBonusVal DECIMAL(5, 2),
    foodBonusCap INT,
    PRIMARY KEY (itemID, attributeTypeID),
    FOREIGN KEY (itemID) REFERENCES Item (itemID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (attributeTypeID) REFERENCES AttributeType (attributeTypeID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CHECK (
        -- Either bonusVal is provided, or both foodBonusVal and foodBonusCap are provided, but not both sets
        (
            bonusVal IS NOT NULL
            AND foodBonusVal IS NULL
            AND foodBonusCap IS NULL
        )
        OR (
            bonusVal IS NULL
            AND foodBonusVal IS NOT NULL
            AND foodBonusCap IS NOT NULL
        )
    )
);
-- Creating the Consumables table, which is a subtype of Item
CREATE TABLE Consumables (
    foodID INT PRIMARY KEY,
    description VARCHAR(255),
    FOREIGN KEY (foodID) REFERENCES Item (itemID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- Creating the InventorySlot table
CREATE TABLE InventorySlot (
    inventorySlotID INT PRIMARY KEY,
    CONSTRAINT chk_inventorySlotID_range CHECK (
        inventorySlotID BETWEEN 1 AND 10
    )
);
-- Creating the ItemStack table
CREATE TABLE ItemStack (
    itemStackID INT AUTO_INCREMENT PRIMARY KEY,
    inventorySlotID INT,
    itemID INT,
    quantity INT CHECK (quantity > 0),
    FOREIGN KEY (inventorySlotID) REFERENCES InventorySlot (inventorySlotID),
    FOREIGN KEY (itemID) REFERENCES Item (itemID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- Creating the Inventory table
CREATE TABLE Inventory (
    characterID INT,
    inventorySlotID INT,
    itemStackID INT,
    PRIMARY KEY (characterID, inventorySlotID),
    FOREIGN KEY (characterID) REFERENCES Chara (characterID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (itemStackID) REFERENCES ItemStack (itemStackID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (inventorySlotID) REFERENCES InventorySlot (inventorySlotID)
);
-- Creating the JobSpecificEquipment table
CREATE TABLE JobSpecificEquipment (
    equipmentID INT,
    jobID INT,
    PRIMARY KEY (equipmentID, jobID),
    FOREIGN KEY (equipmentID) REFERENCES Equipment (equipmentID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (jobID) REFERENCES Job (jobID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
-- Creating the EquippedItems table 
CREATE TABLE EquippedItems (
    characterID INT,
    equipSlotID INT,
    equipmentID INT,
    PRIMARY KEY (characterID, equipSlotID),
    FOREIGN KEY (characterID) REFERENCES Chara (characterID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (equipSlotID) REFERENCES EquipmentSlot (equipSlotID),
    FOREIGN KEY (equipmentID) REFERENCES Equipment (equipmentID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- Trigger to validate stack size before inserting new item stacks
-- Ensures the quantity doesn't exceed the item's maximum stack size

DELIMITER //
CREATE TRIGGER check_equipment_type_insert 
BEFORE INSERT ON EquippedItems 
FOR EACH ROW 
BEGIN
    -- Rule 1: Weapon slot (slot 1) can't be empty
    IF NEW.equipSlotID = 1 AND NEW.equipmentID IS NULL THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Weapon slot (1) cannot be empty';
    END IF;

    -- Rule 2: Slot 1 must be weapon, others must be gear
    IF NEW.equipmentID IS NOT NULL THEN
        IF NEW.equipSlotID = 1 THEN
            -- Check if it's a weapon
            IF NOT EXISTS (SELECT 1 FROM Weapons WHERE weaponID = NEW.equipmentID) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only weapons can go in slot 1';
            END IF;
        ELSE
            -- Check if it's gear
            IF NOT EXISTS (SELECT 1 FROM Gears WHERE gearID = NEW.equipmentID) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only gear can go in slots 2-10';
            END IF;
        END IF;
    END IF;
END//

CREATE TRIGGER check_equipment_type_update 
BEFORE UPDATE ON EquippedItems 
FOR EACH ROW 
BEGIN
    -- Rule 1: Weapon slot (slot 1) can't be empty
    IF NEW.equipSlotID = 1 AND NEW.equipmentID IS NULL THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Weapon slot (1) cannot be empty';
    END IF;

    -- Rule 2: Slot 1 must be weapon, others must be gear
    IF NEW.equipmentID IS NOT NULL THEN
        IF NEW.equipSlotID = 1 THEN
            -- Check if it's a weapon
            IF NOT EXISTS (SELECT 1 FROM Weapons WHERE weaponID = NEW.equipmentID) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only weapons can go in slot 1';
            END IF;
        ELSE
            -- Check if it's gear
            IF NOT EXISTS (SELECT 1 FROM Gears WHERE gearID = NEW.equipmentID) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only gear can go in slots 2-10';
            END IF;
        END IF;
    END IF;
END//
DELIMITER ;


INSERT INTO Player (email, playerName, isActive) VALUES
    ('player1@example.com', 'Player One', TRUE),
    ('player2@example.com', 'Player Two', FALSE),
    ('player3@example.com', 'Player Three', TRUE),
    ('player4@example.com', 'Player Four', TRUE),
    ('player5@example.com', 'Player Five', FALSE);

INSERT INTO Chara (firstName, lastName, playerEmail, HP, MP) VALUES
    ('John', 'Doe', 'player1@example.com', 100, 50),
    ('Jane', 'Smith', 'player2@example.com', 120, 60),
    ('Sam', 'Brown', 'player3@example.com', 110, 70),
    ('Lucy', 'Jones', 'player4@example.com', 130, 55),
    ('Tom', 'White', 'player5@example.com', 105, 65);

-- Insert equipment slots
INSERT INTO EquipmentSlot (equipSlotID, slotName, slotType) VALUES
(1, 'Weapon Slot', 'weapon'),
(2, 'Head Gear', 'gear'),
(3, 'Chest Gear', 'gear'),
(4, 'Hand Gear', 'gear');


-- Insert some items with their itemLevels
INSERT INTO Item (itemID, itemName, maxStackSize, isSellable, vendorPrice, itemLevel) VALUES
(1, 'Basic Sword', 1, TRUE, 100, 1),    -- Starter weapon
(2, 'Iron Helmet', 1, TRUE, 50, 5),     -- Basic armor
(3, 'Steel Sword', 1, TRUE, 200, 15),   -- Mid-tier weapon
(4, 'Leather Armor', 1, TRUE, 75, 10),  -- Mid-tier armor
(5, 'Magic Staff', 1, TRUE, 150, 20);   -- High-tier weapon

-- Insert equipment
INSERT INTO Equipment (equipmentID, requiredLevel, equipmentType) VALUES
(1, 1, 'weapon'),  -- Basic Sword
(2, 1, 'gear'),    -- Iron Helmet
(3, 5, 'weapon'),  -- Steel Sword
(4, 3, 'gear'),    -- Leather Armor
(5, 10, 'weapon'); -- Magic Staff

-- Insert weapons
INSERT INTO Weapons (weaponID, damageDone, autoAttack, attackDelay) VALUES
(1, 10, TRUE, 3),  -- Basic Sword
(3, 15, TRUE, 3),  -- Steel Sword
(5, 20, FALSE, 4); -- Magic Staff

-- Insert gears
INSERT INTO Gears (gearID, equipSlotID, defenseRating, magicDefenseRating) VALUES
(2, 2, 5, 2),      -- Iron Helmet
(4, 3, 8, 3);      -- Leather Armor

-- TEST CASE 1: Valid weapon equip (Should PASS)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID)
VALUES (1, 1, 1);  -- Character 1 equips Basic Sword in weapon slot

-- TEST CASE 2: Valid gear equip (Should PASS)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID)
VALUES (1, 2, 2);  -- Character 1 equips Iron Helmet in head slot

-- TEST CASE 3: Empty weapon slot (Should FAIL)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID)
VALUES (2, 1, NULL);  -- Try to leave weapon slot empty

-- TEST CASE 4: Empty gear slot (Should PASS)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID)
VALUES (2, 2, NULL);  -- Empty head slot is allowed

-- TEST CASE 5: Wrong equipment type (Should FAIL)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID)
VALUES (3, 1, 2);  -- Try to put gear (helmet) in weapon slot

-- TEST CASE 6: Wrong equipment type (Should FAIL)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID)
VALUES (3, 2, 1);  -- Try to put weapon in gear slot

-- TEST CASE 7: Update tests - Valid update (Should PASS)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID)
VALUES (4, 1, 1);  -- First equip Basic Sword
UPDATE EquippedItems 
SET equipmentID = 3  -- Update to Steel Sword
WHERE characterID = 4 AND equipSlotID = 1;

-- TEST CASE 8: Update tests - Invalid update (Should FAIL)
UPDATE EquippedItems 
SET equipmentID = NULL  -- Try to remove weapon
WHERE characterID = 4 AND equipSlotID = 1;

-- TEST CASE 9: Multiple slots for same character (Should PASS)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID) VALUES
(5, 1, 5),  -- Magic Staff in weapon slot
(5, 2, 2),  -- Iron Helmet in head slot
(5, 3, 4);  -- Leather Armor in chest slot

-- TEST CASE 10: Try to equip same item twice (Should be handled by PRIMARY KEY)
INSERT INTO EquippedItems (characterID, equipSlotID, equipmentID)
VALUES (1, 1, 1),  -- Try to equip Basic Sword again in same slot
      (1, 2, 2);  -- Try to equip Iron Helmet again in same slot
