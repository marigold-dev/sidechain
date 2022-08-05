"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var fc = require("fast-check");
var generators_1 = require("./generators");
var state_1 = require("../src/state");
describe('cookieBaker.add_XXX without enough', function () {
    test('Cannot mint idleverse if not enough cookie', function () {
        fc.assert(fc.property((0, generators_1.cookieBakerArbitrary)(), function (cookieBakerType) {
            var cursorsBefore = cookieBakerType.numberOfCursor;
            var grandmasBefore = cookieBakerType.numberOfGrandma;
            var farmsBefore = cookieBakerType.numberOfFarm;
            var minesBefore = cookieBakerType.numberOfMine;
            var factoriesBefore = cookieBakerType.numberOfFactory;
            var banksBefore = cookieBakerType.numberOfBank;
            var templesBefore = cookieBakerType.numberOfTemple;
            var wizardsBefore = cookieBakerType.numberOfWizard;
            var shipmentsBefore = cookieBakerType.numberOfShipment;
            var alchemiesBefore = cookieBakerType.numberOfAlchemy;
            var portalsBefore = cookieBakerType.numberOfPortal;
            var timemachinesBefore = cookieBakerType.numberOfTimeMachine;
            var antimattersBefore = cookieBakerType.numberOfAntimatter;
            var prismsBefore = cookieBakerType.numberOfPrism;
            var chancemakersBefore = cookieBakerType.numberOfChanceMaker;
            var fractalsBefore = cookieBakerType.numberOfFractal;
            var javascriptsBefore = cookieBakerType.numberOfJavaScript;
            var idleversesBefore = cookieBakerType.numberOfIdleverse;
            var cordexsBefore = cookieBakerType.numberOfCordex;
            var freeCursorBefore = cookieBakerType.numberOfFreeCursor;
            var freeGrandmaBefore = cookieBakerType.numberOfFreeGrandma;
            var freeFarmBefore = cookieBakerType.numberOfFreeFarm;
            var freeMineBefore = cookieBakerType.numberOfFreeMine;
            var freeFactoryBefore = cookieBakerType.numberOfFreeFactory;
            var freeBankBefore = cookieBakerType.numberOfFreeBank;
            var freeTempleBefore = cookieBakerType.numberOfFreeTemple;
            var freeWizardBefore = cookieBakerType.numberOfFreeWizard;
            var freeShipmentBefore = cookieBakerType.numberOfFreeShipment;
            var freeAlchemyBefore = cookieBakerType.numberOfFreeAlchemy;
            var freePortalBefore = cookieBakerType.numberOfFreePortal;
            var freeTimeMachinesBefore = cookieBakerType.numberOfFreeTimeMachine;
            var freeAntimatterBefore = cookieBakerType.numberOfFreeAntimatter;
            var freePrismBefore = cookieBakerType.numberOfFreePrism;
            var freeChancemakerBefore = cookieBakerType.numberOfFreeChanceMaker;
            var freeFractalBefore = cookieBakerType.numberOfFreeFractal;
            var freeJavaScriptBefore = cookieBakerType.numberOfFreeJavaScript;
            var freeIdleverseBefore = cookieBakerType.numberOfFreeIdleverse;
            var freeCordexBefore = cookieBakerType.numberOfFreeCordex;
            var cursorCostBefore = cookieBakerType.cursorCost;
            var grandmaCostBefore = cookieBakerType.grandmaCost;
            var farmCostBefore = cookieBakerType.farmCost;
            var mineCostBefore = cookieBakerType.mineCost;
            var factoryCostBefore = cookieBakerType.factoryCost;
            var bankCostBefore = cookieBakerType.bankCost;
            var templeCostBefore = cookieBakerType.templeCost;
            var wizardCostBefore = cookieBakerType.wizardCost;
            var shipmentCostBefore = cookieBakerType.shipmentCost;
            var alchemyCostBefore = cookieBakerType.alchemyCost;
            var portalCostBefore = cookieBakerType.portalCost;
            var timeMachineCostBefore = cookieBakerType.timeMachineCost;
            var antimatterCostBefore = cookieBakerType.antimatterCost;
            var prismCostBefore = cookieBakerType.prismCost;
            var chanceMakerCostBefore = cookieBakerType.chanceMakerCost;
            var fractalCostBefore = cookieBakerType.fractalCost;
            var javaScriptCostBefore = cookieBakerType.javaScriptCost;
            var idleverseCostBefore = cookieBakerType.idleverseCost;
            var cordexCostBefore = cookieBakerType.cordexCost;
            var cursorCpsBefore = cookieBakerType.cursorCps;
            var grandmaCpsBefore = cookieBakerType.grandmaCps;
            var farmCpsBefore = cookieBakerType.farmCps;
            var mineCpsBefore = cookieBakerType.mineCps;
            var factoryCpsBefore = cookieBakerType.factoryCps;
            var bankCpsBefore = cookieBakerType.bankCps;
            var templeCpsBefore = cookieBakerType.templeCps;
            var wizardCpsBefore = cookieBakerType.wizardCps;
            var shipmentCpsBefore = cookieBakerType.shipmentCps;
            var alchemyCpsBefore = cookieBakerType.alchemyCps;
            var portalCpsBefore = cookieBakerType.portalCps;
            var timeMachineCpsBefore = cookieBakerType.timeMachineCps;
            var antimatterCpsBefore = cookieBakerType.antimatterCps;
            var prismCpsBefore = cookieBakerType.prismCps;
            var chanceMakerCpsBefore = cookieBakerType.chanceMakerCps;
            var fractalCpsBefore = cookieBakerType.fractalCps;
            var javaScriptCpsBefore = cookieBakerType.javaScriptCps;
            var idleverseCpsBefore = cookieBakerType.idleverseCps;
            var cordexCpsBefore = cookieBakerType.cordexCps;
            //make sure we can't buy a idleverse
            cookieBakerType.numberOfCookie = 0;
            var cookieBaker = (0, state_1.addIdleverse)(cookieBakerType);
            return (cookieBaker.numberOfCookie === 0
                && cookieBaker.numberOfCursor === cursorsBefore
                && cookieBaker.numberOfGrandma === grandmasBefore
                && cookieBaker.numberOfFarm === farmsBefore
                && cookieBaker.numberOfMine === minesBefore
                && cookieBaker.numberOfFactory === factoriesBefore
                && cookieBaker.numberOfBank === banksBefore
                && cookieBaker.numberOfTemple === templesBefore
                && cookieBaker.numberOfWizard === wizardsBefore
                && cookieBaker.numberOfShipment === shipmentsBefore
                && cookieBaker.numberOfAlchemy === alchemiesBefore
                && cookieBaker.numberOfPortal === portalsBefore
                && cookieBaker.numberOfTimeMachine === timemachinesBefore
                && cookieBaker.numberOfAntimatter === antimattersBefore
                && cookieBaker.numberOfPrism === prismsBefore
                && cookieBaker.numberOfChanceMaker === chancemakersBefore
                && cookieBaker.numberOfFractal === fractalsBefore
                && cookieBaker.numberOfJavaScript === javascriptsBefore
                && cookieBaker.numberOfIdleverse === idleversesBefore
                && cookieBaker.numberOfCordex === cordexsBefore
                && cookieBaker.numberOfFreeCursor === freeCursorBefore
                && cookieBaker.numberOfFreeGrandma === freeGrandmaBefore
                && cookieBaker.numberOfFreeFarm === freeFarmBefore
                && cookieBaker.numberOfFreeMine === freeMineBefore
                && cookieBaker.numberOfFreeFactory === freeFactoryBefore
                && cookieBaker.numberOfFreeBank === freeBankBefore
                && cookieBaker.numberOfFreeTemple === freeTempleBefore
                && cookieBaker.numberOfFreeWizard === freeWizardBefore
                && cookieBaker.numberOfFreeShipment === freeShipmentBefore
                && cookieBaker.numberOfFreeAlchemy === freeAlchemyBefore
                && cookieBaker.numberOfFreePortal === freePortalBefore
                && cookieBaker.numberOfFreeTimeMachine === freeTimeMachinesBefore
                && cookieBaker.numberOfFreeAntimatter === freeAntimatterBefore
                && cookieBaker.numberOfFreePrism === freePrismBefore
                && cookieBaker.numberOfFreeChanceMaker === freeChancemakerBefore
                && cookieBaker.numberOfFreeFractal === freeFractalBefore
                && cookieBaker.numberOfFreeJavaScript === freeJavaScriptBefore
                && cookieBaker.numberOfFreeIdleverse === freeIdleverseBefore
                && cookieBaker.numberOfFreeCordex === freeCordexBefore
                && cookieBaker.cursorCost === cursorCostBefore
                && cookieBaker.grandmaCost === grandmaCostBefore
                && cookieBaker.farmCost === farmCostBefore
                && cookieBaker.mineCost === mineCostBefore
                && cookieBaker.factoryCost === factoryCostBefore
                && cookieBaker.bankCost === bankCostBefore
                && cookieBaker.templeCost === templeCostBefore
                && cookieBaker.wizardCost === wizardCostBefore
                && cookieBaker.shipmentCost === shipmentCostBefore
                && cookieBaker.alchemyCost === alchemyCostBefore
                && cookieBaker.portalCost === portalCostBefore
                && cookieBaker.timeMachineCost === timeMachineCostBefore
                && cookieBaker.antimatterCost === antimatterCostBefore
                && cookieBaker.prismCost === prismCostBefore
                && cookieBaker.chanceMakerCost === chanceMakerCostBefore
                && cookieBaker.fractalCost === fractalCostBefore
                && cookieBaker.javaScriptCost === javaScriptCostBefore
                && cookieBaker.idleverseCost === idleverseCostBefore
                && cookieBaker.cordexCost === cordexCostBefore
                && cookieBaker.cursorCps === cursorCpsBefore
                && cookieBaker.grandmaCps === grandmaCpsBefore
                && cookieBaker.farmCps === farmCpsBefore
                && cookieBaker.mineCps === mineCpsBefore
                && cookieBaker.factoryCps === factoryCpsBefore
                && cookieBaker.bankCps === bankCpsBefore
                && cookieBaker.templeCps === templeCpsBefore
                && cookieBaker.wizardCps === wizardCpsBefore
                && cookieBaker.shipmentCps === shipmentCpsBefore
                && cookieBaker.alchemyCps === alchemyCpsBefore
                && cookieBaker.portalCps === portalCpsBefore
                && cookieBaker.timeMachineCps === timeMachineCpsBefore
                && cookieBaker.antimatterCps === antimatterCpsBefore
                && cookieBaker.prismCps === prismCpsBefore
                && cookieBaker.chanceMakerCps === chanceMakerCpsBefore
                && cookieBaker.fractalCps === fractalCpsBefore
                && cookieBaker.javaScriptCps === javaScriptCpsBefore
                && cookieBaker.idleverseCps === idleverseCpsBefore
                && cookieBaker.cordexCps === cordexCpsBefore);
        }), { verbose: true });
    });
});
