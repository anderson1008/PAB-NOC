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
//    File: TPZSimpleRouterFlowBless.hpp
//
//    Class: TPZSimpleRouterFlowBless
//
//    Inherited from: TPZFlow
// :
//*************************************************************************
//end of header


#ifndef __TPZSimpleRouterFlowBless_HPP__
#define __TPZSimpleRouterFlowBless_HPP__

//*************************************************************************

   #include <TPZFlow.hpp>

   #ifndef __TPZArray_HPP__
   #include <TPZArray.hpp>
   #endif

   #ifndef __TPZPriorityQueue_HPP__
   #include <TPZPriorityQueue.hpp>
   #endif

   #ifndef __TPZQueue_HPP__
   #include <TPZQueue.hpp>
   #endif

   #ifndef __TPZPair_HPP__
   #include <TPZPair.hpp>
   #endif

   #ifndef __TPZNetworkTorus_HPP__
   #include <TPZNetworkTorus.hpp>
   #endif

   /// This has to be changed later.
	//#define EPOCH 4 * 3 + 4 // networkSize x routerDelay + latency of the following body flits when they tranmitted throught the minimal path.
   //#define MAXINJECT 10000

//*************************************************************************

   class TPZMessage;


//*************************************************************************

   typedef TPZPriorityQueue<TPZMessage*>      TPZArbitrationQueue;
   typedef TPZQueue<TPZMessage*>              TPZInjectionQueue;
//*************************************************************************

   class TPZSimpleRouterFlowBless : public TPZFlow
   {
      typedef TPZFlow Inhereited;

   public:
      TPZSimpleRouterFlowBless( TPZComponent& component);
      virtual ~TPZSimpleRouterFlowBless();

      virtual void initialize();
      virtual void terminate();

      virtual Boolean controlAlgoritm(Boolean info=false, int delta=0);
      virtual Boolean inputReading();
      virtual Boolean stateChange();
      virtual Boolean outputWriting();

      virtual Boolean onReadyUp(unsigned interfaz, unsigned cv);
      virtual Boolean onStopUp(unsigned interfaz, unsigned cv);
      virtual Boolean onStopDown(unsigned interfaz, unsigned cv);
      virtual TPZString getStatus() const;

		// Anderson's Implementation

      // CHIPPER
		unsigned steering (TPZROUTINGTYPE desiredDirection, unsigned stage);
		TPZMessage * winner (TPZMessage * msgCh0, TPZMessage * msgCh1);
      bool swapFlitCtrl (unsigned flit0DesiredPort, unsigned flit1DesiredPort, unsigned winningChannel);
      void swapFlit (TPZMessage * inFlit0, TPZMessage * inFlit1, TPZMessage * &outFlit0, TPZMessage * \
                     &outFlit1, bool swapEnable);
		bool permuterBlock (TPZMessage * msg0, TPZMessage * msg1, unsigned stage, unsigned pos);
		void goldenEpochSequencing (unsigned time);
		Boolean goldenCheck (unsigned pktId); // output should be fed in winner();
		TPZMessage * ejector ();
      Boolean routeComputation(TPZMessage* msg);
      void portUtilizationReset (unsigned time);
      // End of CHIPPER

      // PAB-NOC
      virtual void updatePG (unsigned interfaz, unsigned cv);
      void portPowerGate (unsigned time);
      unsigned updatePGLevel ();
      unsigned getRouterLoad ();
      PORTTYPE getPortType (TPZROUTINGTYPE direction);
      void setPortType (unsigned time);
      unsigned indexMapping (unsigned outIndex);
      void silverCheck (unsigned time);
      void setInterval ();
      void updateHistory (unsigned time);
      //unsigned getPGEpoch () {return EpochPG;}

      enum PORTSTATE {INACTIVE=0, ACTIVE, TRANSIENT, WAKEUPTX, WAKEUPRX};

      unsigned EpochPG;
      unsigned thresholdPG;
      unsigned thresholdPGWU;
      unsigned thresholdPGLevel2;
      unsigned thresholdPGLevel3;
      unsigned WAKEUPDELAY;
      unsigned RINGSIZE_PGST1;
      unsigned RINGSIZE_PGST2;
      unsigned RINGSIZE_PGST3;


		// end of PAB-NOC

		// End of Anderson's Implementation

      // Run time information
      DEFINE_RTTI(TPZSimpleRouterFlowBless);

   protected:
      virtual  void    cleanOutputInterfaces();
      virtual  void    cleanInputInterfaces();

      virtual  Boolean updateMessageInfo(TPZMessage* msg, unsigned outPort);
      virtual  Boolean getDeltaAbs(TPZMessage* msg, unsigned outPort);
      virtual  Boolean dispatchEvent(const TPZEvent& event);

   protected:
      Boolean cleanInterfaces() const
      { return m_CleanInterfaces; }
      void setCleanInterfaces(Boolean value)
      { m_CleanInterfaces = value; }
      Boolean m_CleanInterfaces;

   protected:
      unsigned *m_connections;
      TPZMessage** m_sync;
      TPZArbitrationQueue m_priorityQueue;
      TPZInjectionQueue m_injectionQueue;
      Boolean* m_connEstablished;
      unsigned m_ports;
      // CHIPPER Support
      TPZMessage** m_pipeReg1;
      TPZMessage** m_pipeReg2;
      unsigned long pktIdGolden;
      Boolean * m_eject;
      TPZMessage ** m_interFlitSt1;
      TPZMessage ** m_interFlitSt2;
	 	TPZMessage ** m_outFlit; // output of the second stage.
      unsigned * m_portUtilCount; // port utilization counter;
      unsigned * m_wakeupDelay; // use to emulate the wakeup delay, not an actual hardware.
      PORTSTATE * m_portState;
      // end CHIPPER Support
      Boolean * m_PG;
      Boolean * m_WU;
      Boolean * m_ACK;
      unsigned m_PGLevel;
      PORTTYPE * m_portType; // port 0 is void. Using port 1-4 in order to conform to TOPOAZ naming routine.
      unsigned ** m_historyPktID;
      unsigned ** m_historyFlitNum;
      unsigned int ringHopCount;
      unsigned int updataInterval; // = celling (ringHopCount/3);
      double * m_consecutivePG;
};




#define THsd  0.1  // shutdown threshold value ; To be investigated.

//*************************************************************************



#endif


// end of file
