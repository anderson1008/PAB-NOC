//
//   Copyright (C) 1998-2011 by Galerna Project, the University of
//   Cantabria, Spain.
//
//   This file is part of the TOPAZ network simulator, originallty developed
//   at the Unviersity of Cantabria
//
//   TOPAZ shares a large proportion of code with SICOSYS which was
//   developed by V.Puente and J.M.Prellezo
//
//   TOPAZ has been developed by P.Abad, L.G.Menezo, P.Prieto and
//   V.Puente
//
//  --------------------------------------------------------------------
//
//  If your use of this software contributes to a published paper, we
//  request that you (1) cite our summary paper that appears on our
//  website (http://www.atc.unican.es/topaz/) and (2) e-mail a citation
//  for your published paper to topaz@atc.unican.es
//
//  If you redistribute derivatives of this software, we request that
//  you notify us and either (1) ask people to register with us at our
//  website (http://www.atc.unican.es/topaz/) or (2) collect registration
//  information and periodically send it to us.
//
//   --------------------------------------------------------------------
//
//   TOPAZ is free software; you can redistribute it and/or
//   modify it under the terms of version 2 of the GNU General Public
//   License as published by the Free Software Foundation.
//
//   TOPAZ is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//   General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with the TOPAZ simulator; if not, write to the Free Software
//   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
//   02111-1307, USA
//
//   The GNU General Public License is contained in the file LICENSE.
//
//
//*************************************************************************
//:
//    File: TPZNetworkTorus.hpp
//
//    Class:
//
//    Inherited from:
// :
//*************************************************************************
//end of header


#ifndef __TPZNetworkTorus_HPP__
#define __TPZNetworkTorus_HPP__

//*************************************************************************

   #include <TPZNetwork.hpp>

//*************************************************************************

   class TPZNetworkBuilder;
   extern unsigned networkSize; // CHIPPER Support
   enum PORTTYPE {_NONPERMANENT_, _PERMANENT_}; // PAB-NOC Support

class PGNode {

   public:
      PGNode (unsigned posX, unsigned posY, unsigned pglevel, PORTTYPE E, PORTTYPE W, PORTTYPE N, PORTTYPE S) : posX(posX), posY(posY), PGLevel(pglevel)
      {
         portType[1] = E;
         portType[2] = W;
         portType[3] = N;
         portType[4] = S;
      }
      //~PGNode ();
      unsigned getPosX ();
      unsigned getPosY ();
      unsigned getPGLevel ();
      PORTTYPE getPortType (TPZROUTINGTYPE);
      bool isCurrentNode (unsigned, unsigned, unsigned);


   private:
      unsigned posX, posY;
      unsigned PGLevel;
      PORTTYPE  portType [5]; // port 0 is void. Using port 1-4 in order to conform to TOPOAZ naming routine.

};


//*************************************************************************

   class TPZNetworkTorus : public TPZNetwork
   {
      friend class TPZNetworkBuilder;

   public:
      TPZNetworkTorus( const TPZComponentId& id,
                       const TPZString& routerId,
                       unsigned x,
                       unsigned y,
                       unsigned z=1 );
      ~TPZNetworkTorus();

      // For PAB-NOC PG Support
      void createPGTable ();
      vector<PGNode> * getPGTable ();

      // end PAB-NOC
      virtual void initialize();
      virtual TPZString asString() const;
      unsigned getDiameter() const;

      virtual unsigned distance(const TPZPosition& src, const TPZPosition& dst);
      virtual void     routingRecord( const TPZPosition& src,
                                      const TPZPosition& dst,
                                      int&  deltaX,
                                      int&  deltaY,
                                      int&  deltaZ,
                                      Boolean ordered=false);

      virtual void generateDORMasks(TPZRouter* router);

      virtual unsigned long long setMulticastMask(const TPZPosition& current,
                                         const TPZROUTINGTYPE& direction);
      // Run time information
      DEFINE_RTTI(TPZNetworkTorus);

   private:
      static TPZNetworkTorus* newFrom(const TPZTag* tag, TPZComponent* owner);
      vector<PGNode> PGVector;
   };

//*************************************************************************


#endif


// end of file
