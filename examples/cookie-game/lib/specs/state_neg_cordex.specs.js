"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var fc = require("fast-check");
var generators_1 = require("./generators");
var state_1 = require("../src/state");
describe('cookieBaker.add_XXX without enough', function () {
    test('Cannot cordex bank if not enough cookie', function () {
        fc.assert(fc.property((0, generators_1.cookieBakerArbitrary)(), function (cookieBaker) {
            var cursorsBefore = cookieBaker.numberOfCursor;
            var grandmasBefore = cookieBaker.numberOfGrandma;
            var farmsBefore = cookieBaker.numberOfFarm;
            var minesBefore = cookieBaker.numberOfMine;
            var factoriesBefore = cookieBaker.numberOfFactory;
            var banksBefore = cookieBaker.numberOfBank;
            var templesBefore = cookieBaker.numberOfTemple;
            var wizardsBefore = cookieBaker.numberOfWizard;
            var shipmentsBefore = cookieBaker.numberOfShipment;
            var alchemiesBefore = cookieBaker.numberOfAlchemy;
            var portalsBefore = cookieBaker.numberOfPortal;
            var timemachinesBefore = cookieBaker.numberOfTimeMachine;
            var antimattersBefore = cookieBaker.numberOfAntimatter;
            var prismsBefore = cookieBaker.numberOfPrism;
            var chancemakersBefore = cookieBaker.numberOfChanceMaker;
            var fractalsBefore = cookieBaker.numberOfFractal;
            var javascriptsBefore = cookieBaker.numberOfJavaScript;
            var idleversesBefore = cookieBaker.numberOfIdleverse;
            var cordexsBefore = cookieBaker.numberOfCordex;
            var freeCursorBefore = cookieBaker.numberOfFreeCursor;
            var freeGrandmaBefore = cookieBaker.numberOfFreeGrandma;
            var freeFarmBefore = cookieBaker.numberOfFreeFarm;
            var freeMineBefore = cookieBaker.numberOfFreeMine;
            var freeFactoryBefore = cookieBaker.numberOfFreeFactory;
            var freeBankBefore = cookieBaker.numberOfFreeBank;
            var freeTempleBefore = cookieBaker.numberOfFreeTemple;
            var freeWizardBefore = cookieBaker.numberOfFreeWizard;
            var freeShipmentBefore = cookieBaker.numberOfFreeShipment;
            var freeAlchemyBefore = cookieBaker.numberOfFreeAlchemy;
            var freePortalBefore = cookieBaker.numberOfFreePortal;
            var freeTimeMachinesBefore = cookieBaker.numberOfFreeTimeMachine;
            var freeAntimatterBefore = cookieBaker.numberOfFreeAntimatter;
            var freePrismBefore = cookieBaker.numberOfFreePrism;
            var freeChancemakerBefore = cookieBaker.numberOfFreeChanceMaker;
            var freeFractalBefore = cookieBaker.numberOfFreeFractal;
            var freeJavaScriptBefore = cookieBaker.numberOfFreeJavaScript;
            var freeIdleverseBefore = cookieBaker.numberOfFreeIdleverse;
            var freeCordexBefore = cookieBaker.numberOfFreeCordex;
            var cursorCostBefore = cookieBaker.cursorCost;
            var grandmaCostBefore = cookieBaker.grandmaCost;
            var farmCostBefore = cookieBaker.farmCost;
            var mineCostBefore = cookieBaker.mineCost;
            var factoryCostBefore = cookieBaker.factoryCost;
            var bankCostBefore = cookieBaker.bankCost;
            var templeCostBefore = cookieBaker.templeCost;
            var wizardCostBefore = cookieBaker.wizardCost;
            var shipmentCostBefore = cookieBaker.shipmentCost;
            var alchemyCostBefore = cookieBaker.alchemyCost;
            var portalCostBefore = cookieBaker.portalCost;
            var timeMachineCostBefore = cookieBaker.timeMachineCost;
            var antimatterCostBefore = cookieBaker.antimatterCost;
            var prismCostBefore = cookieBaker.prismCost;
            var chanceMakerCostBefore = cookieBaker.chanceMakerCost;
            var fractalCostBefore = cookieBaker.fractalCost;
            var javaScriptCostBefore = cookieBaker.javaScriptCost;
            var idleverseCostBefore = cookieBaker.idleverseCost;
            var cordexCostBefore = cookieBaker.cordexCost;
            var cursorCpsBefore = cookieBaker.cursorCps;
            var grandmaCpsBefore = cookieBaker.grandmaCps;
            var farmCpsBefore = cookieBaker.farmCps;
            var mineCpsBefore = cookieBaker.mineCps;
            var factoryCpsBefore = cookieBaker.factoryCps;
            var bankCpsBefore = cookieBaker.bankCps;
            var templeCpsBefore = cookieBaker.templeCps;
            var wizardCpsBefore = cookieBaker.wizardCps;
            var shipmentCpsBefore = cookieBaker.shipmentCps;
            var alchemyCpsBefore = cookieBaker.alchemyCps;
            var portalCpsBefore = cookieBaker.portalCps;
            var timeMachineCpsBefore = cookieBaker.timeMachineCps;
            var antimatterCpsBefore = cookieBaker.antimatterCps;
            var prismCpsBefore = cookieBaker.prismCps;
            var chanceMakerCpsBefore = cookieBaker.chanceMakerCps;
            var fractalCpsBefore = cookieBaker.fractalCps;
            var javaScriptCpsBefore = cookieBaker.javaScriptCps;
            var idleverseCpsBefore = cookieBaker.idleverseCps;
            var cordexCpsBefore = cookieBaker.cordexCps;
            //make sure we can't buy a cordex
            cookieBaker.numberOfCookie = 0;
            var cookie_Baker = (0, state_1.addCordex)(cookieBaker);
            return (cookie_Baker.numberOfCookie === 0
                && cookie_Baker.numberOfCursor === cursorsBefore
                && cookie_Baker.numberOfGrandma === grandmasBefore
                && cookie_Baker.numberOfFarm === farmsBefore
                && cookie_Baker.numberOfMine === minesBefore
                && cookie_Baker.numberOfFactory === factoriesBefore
                && cookie_Baker.numberOfBank === banksBefore
                && cookie_Baker.numberOfTemple === templesBefore
                && cookie_Baker.numberOfWizard === wizardsBefore
                && cookie_Baker.numberOfShipment === shipmentsBefore
                && cookie_Baker.numberOfAlchemy === alchemiesBefore
                && cookie_Baker.numberOfPortal === portalsBefore
                && cookie_Baker.numberOfTimeMachine === timemachinesBefore
                && cookie_Baker.numberOfAntimatter === antimattersBefore
                && cookie_Baker.numberOfPrism === prismsBefore
                && cookie_Baker.numberOfChanceMaker === chancemakersBefore
                && cookie_Baker.numberOfFractal === fractalsBefore
                && cookie_Baker.numberOfJavaScript === javascriptsBefore
                && cookie_Baker.numberOfIdleverse === idleversesBefore
                && cookie_Baker.numberOfCordex === cordexsBefore
                && cookie_Baker.numberOfFreeCursor === freeCursorBefore
                && cookie_Baker.numberOfFreeGrandma === freeGrandmaBefore
                && cookie_Baker.numberOfFreeFarm === freeFarmBefore
                && cookie_Baker.numberOfFreeMine === freeMineBefore
                && cookie_Baker.numberOfFreeFactory === freeFactoryBefore
                && cookie_Baker.numberOfFreeBank === freeBankBefore
                && cookie_Baker.numberOfFreeTemple === freeTempleBefore
                && cookie_Baker.numberOfFreeWizard === freeWizardBefore
                && cookie_Baker.numberOfFreeShipment === freeShipmentBefore
                && cookie_Baker.numberOfFreeAlchemy === freeAlchemyBefore
                && cookie_Baker.numberOfFreePortal === freePortalBefore
                && cookie_Baker.numberOfFreeTimeMachine === freeTimeMachinesBefore
                && cookie_Baker.numberOfFreeAntimatter === freeAntimatterBefore
                && cookie_Baker.numberOfFreePrism === freePrismBefore
                && cookie_Baker.numberOfFreeChanceMaker === freeChancemakerBefore
                && cookie_Baker.numberOfFreeFractal === freeFractalBefore
                && cookie_Baker.numberOfFreeJavaScript === freeJavaScriptBefore
                && cookie_Baker.numberOfFreeIdleverse === freeIdleverseBefore
                && cookie_Baker.numberOfFreeCordex === freeCordexBefore
                && cookie_Baker.cursorCost === cursorCostBefore
                && cookie_Baker.grandmaCost === grandmaCostBefore
                && cookie_Baker.farmCost === farmCostBefore
                && cookie_Baker.mineCost === mineCostBefore
                && cookie_Baker.factoryCost === factoryCostBefore
                && cookie_Baker.bankCost === bankCostBefore
                && cookie_Baker.templeCost === templeCostBefore
                && cookie_Baker.wizardCost === wizardCostBefore
                && cookie_Baker.shipmentCost === shipmentCostBefore
                && cookie_Baker.alchemyCost === alchemyCostBefore
                && cookie_Baker.portalCost === portalCostBefore
                && cookie_Baker.timeMachineCost === timeMachineCostBefore
                && cookie_Baker.antimatterCost === antimatterCostBefore
                && cookie_Baker.prismCost === prismCostBefore
                && cookie_Baker.chanceMakerCost === chanceMakerCostBefore
                && cookie_Baker.fractalCost === fractalCostBefore
                && cookie_Baker.javaScriptCost === javaScriptCostBefore
                && cookie_Baker.idleverseCost === idleverseCostBefore
                && cookie_Baker.cordexCost === cordexCostBefore
                && cookie_Baker.cursorCps === cursorCpsBefore
                && cookie_Baker.grandmaCps === grandmaCpsBefore
                && cookie_Baker.farmCps === farmCpsBefore
                && cookie_Baker.mineCps === mineCpsBefore
                && cookie_Baker.factoryCps === factoryCpsBefore
                && cookie_Baker.bankCps === bankCpsBefore
                && cookie_Baker.templeCps === templeCpsBefore
                && cookie_Baker.wizardCps === wizardCpsBefore
                && cookie_Baker.shipmentCps === shipmentCpsBefore
                && cookie_Baker.alchemyCps === alchemyCpsBefore
                && cookie_Baker.portalCps === portalCpsBefore
                && cookie_Baker.timeMachineCps === timeMachineCpsBefore
                && cookie_Baker.antimatterCps === antimatterCpsBefore
                && cookie_Baker.prismCps === prismCpsBefore
                && cookie_Baker.chanceMakerCps === chanceMakerCpsBefore
                && cookie_Baker.fractalCps === fractalCpsBefore
                && cookie_Baker.javaScriptCps === javaScriptCpsBefore
                && cookie_Baker.idleverseCps === idleverseCpsBefore
                && cookie_Baker.cordexCps === cordexCpsBefore);
        }), { verbose: true });
    });
});
