//
// ********************************************************************
// * License and Disclaimer                                           *
// *                                                                  *
// * The  Geant4 software  is  copyright of the Copyright Holders  of *
// * the Geant4 Collaboration.  It is provided  under  the terms  and *
// * conditions of the Geant4 Software License,  included in the file *
// * LICENSE and available at  http://cern.ch/geant4/license .  These *
// * include a list of copyright holders.                             *
// *                                                                  *
// * Neither the authors of this software system, nor their employing *
// * institutes,nor the agencies providing financial support for this *
// * work  make  any representation or  warranty, express or implied, *
// * regarding  this  software system or assume any liability for its *
// * use.  Please see the license in the file  LICENSE  and URL above *
// * for the full disclaimer and the limitation of liability.         *
// *                                                                  *
// * This  code  implementation is the result of  the  scientific and *
// * technical work of the GEANT4 collaboration.                      *
// * By using,  copying,  modifying or  distributing the software (or *
// * any work based  on the software)  you  agree  to acknowledge its *
// * use  in  resulting  scientific  publications,  and indicate your *
// * acceptance of all terms of the Geant4 Software license.          *
// ********************************************************************
//
//
/// \file B1EventAction.cc
/// \brief Implementation of the B1EventAction class

#include "B1EventAction.hh"
#include "B1RunAction.hh"

#include "G4Event.hh"
#include "G4RunManager.hh"

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

B1EventAction::B1EventAction(B1RunAction* runAction)
: G4UserEventAction(),
  fRunAction(runAction),
  fEdep(0.)
{} 

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

B1EventAction::~B1EventAction()
{}

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

void B1EventAction::BeginOfEventAction(const G4Event*event)
{    
  fEdep = 0.;
  G4cout << "Event " << event->GetEventID() << G4endl;


    long fEventSeedIndex = CLHEP::HepRandom::getTheSeed();
    // auto fEventSeed1 = CLHEP::HepRandom::getTheSeeds()[0];
    // auto fEventSeed2 = CLHEP::HepRandom::getTheSeeds()[1];
    long fEventSeed1 = 47399124;
    long fEventSeed2 = 33520851;

    long fEventSeedsArray[2] = {fEventSeed1, fEventSeed2};
    const long int* fEventSeeds = fEventSeedsArray;
    std::cout << "fEventSeed1: "<< fEventSeed1 << std::endl;
    std::cout << "fEventSeed2: "<< fEventSeed2 << std::endl;
    // std::cout << "fEventSeed3: "<< CLHEP::HepRandom::getTheSeeds()[2] << std::endl;
    // std::cout << "fEventSeed4: "<< CLHEP::HepRandom::getTheSeeds()[3] << std::endl;
    // std::cout << "fEventSeed5: "<< CLHEP::HepRandom::getTheSeeds()[4] << std::endl;
    G4Random::setTheSeeds(fEventSeeds,fEventSeedIndex);

}

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

void B1EventAction::EndOfEventAction(const G4Event*)
{   
  // accumulate statistics in run action
  fRunAction->AddEdep(fEdep);
}

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......
