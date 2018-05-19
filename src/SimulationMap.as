package 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.events.Event;
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class SimulationMap extends Sprite 
	{
		private var _parameters:Object;
		private var _plot2D:Plot2D;
		private var _window:Rectangle = new Rectangle(0, 0, 1030, 400);
		
		
		public function SimulationMap() 
		{
			_drawBackground(_window);
		}
		
		private function _drawBackground(window:Rectangle):void{
			graphics.clear();
			// get the bounds of the _clip (_clip would be your movieClip)
			
			var offset:Number = 3;
			
			// draw a box based on the window
			with(this.graphics) {
				lineStyle(3,GlobalVariables._redColor,0.92);
				beginFill(0x000000, 0.92);
				moveTo(window.x - offset, window.y - offset);
				lineTo(window.x + offset + window.width, window.y - offset);
				lineTo(window.x + offset + window.width, window.y + offset + window.height);
				lineTo(window.x - offset, window.y + offset + window.height);
				lineTo(window.x - offset, window.y - offset);
				endFill();
			}
		}
		
		private function _traceResults(labelArray:Array, results:Array, extra:Array, display:Array, destage:Array):void {
			if (_plot2D != null) removeChild(_plot2D);
			_plot2D = new Plot2D(_window.width, _window.height, 30, 10, labelArray, results, extra, display, destage);
			addChild(_plot2D);
		}
		
		private function _getInheritedMass(index:int):Number {
			var stage:Vector.<Array>;
			var j:int = 0;
			var len:int;
			var mass:Number = 0;
			var quantity:int = 0;
			
			for (var i:int = index - 1; i > -1; i--) {
				stage = _parameters[i];
				len = stage.length;
				for (j = 0; j < len; j++ ) {
					quantity = stage[j][2];
					mass += quantity * (stage[j][3] + stage[j][4] + stage[j][5] + stage[j][6] + stage[j][7] + stage[j][8]);
				}
			}
			return mass;
		}
		private function _getPayload(index:int, stage:Vector.<Array>):Number {
			var payload:Number = _getInheritedMass(index);
			var len:int = stage.length;
			for (var i:int = 0; i < len; i++) {
				payload += stage[i][2] * stage[i][3];
			}
			
			return payload;
		}
		
		private function _getFuel(stage:Vector.<Array>):Array {
			//[LOX, LF, Mono, Xe, SRB]
			var fuel:Array = [0, 0, 0, 0, 0];
			var len:int = stage.length;
			for (var i:int = 0; i < len; i++) {
				//quantity * mass_fuel_type * % fuel_factor
				fuel[0] += stage[i][2] * stage[i][4] * stage[i][15] / 100;
				fuel[1] += stage[i][2] * stage[i][5] * stage[i][15] / 100;
				fuel[2] += stage[i][2] * stage[i][7] * stage[i][15] / 100;
				fuel[3] += stage[i][2] * stage[i][8] * stage[i][15] / 100;
				fuel[4] += stage[i][2] * stage[i][6] * stage[i][15] / 100; //SRB only for total mass calculation
			}
			return fuel;
		}
		
		private function _getEngines(index:int):Vector.<Array> {
			//[LOX+LF, Mono, Xe, SRB]
			var stage:Vector.<Array> = _parameters[index];
			var engineL:Array = new Array();
			var engineM:Array = new Array();
			var engineX:Array = new Array();
			var engineS:Array = new Array();
			var len:int = stage.length;
			for (var i:int = 0; i < len; i++) {
				//type 5 : engine LOX/LF, 6 : SRB, 7 : Mono, 8 : Xenon, 9 : tank+engine LOX/LF
				//[thrust_atm, thrust_vac, isp_atm, isp_vac] and for SRB [..., mass_fuel]
				if (stage[i][0] == 5 || stage[i][0] == 9) engineL.push([ stage[i][2] * stage[i][9] * stage[i][16]/100 , stage[i][2] * stage[i][11] * stage[i][16]/100 , stage[i][12], stage[i][14] ]);
				if (stage[i][0] == 7) engineM.push([ stage[i][2] * stage[i][9] * stage[i][16]/100 , stage[i][2] * stage[i][11] * stage[i][16]/100 , stage[i][12], stage[i][14] ]);
				if (stage[i][0] == 8) engineX.push([ stage[i][2] * stage[i][9] * stage[i][16]/100 , stage[i][2] * stage[i][11] * stage[i][16]/100 , stage[i][12], stage[i][14] ]);
				if (stage[i][0] == 6) engineS.push([ stage[i][2] * stage[i][9] * stage[i][16]/100 , stage[i][2] * stage[i][11] * stage[i][16]/100 , stage[i][12], stage[i][14] , stage[i][2] * stage[i][6] * stage[i][15]/100 ]);
			}
			var engine:Vector.<Array> = new <Array>[engineL, engineM, engineX, engineS];
			return engine;
		}
		
		private function _getThrust(engineVector:Vector.<Array>, fuelArray:Array):Number {
			var thrust:Number = 0, i:int;
			if (engineVector[0].length > 0 && fuelArray[0] > 0 && fuelArray[1] > 0) {
				for (i = 0; i < engineVector[0].length; i++) {
					thrust += engineVector[0][i][1];
				}
			}
			if (engineVector[3].length > 0 && fuelArray[4] > 0) {
				for (i = 0; i < engineVector[3].length; i++) {
					if (engineVector[3][i][4] > 0) {
						thrust += engineVector[3][i][1];
					}
				}
			}
			if (engineVector[1].length > 0 && fuelArray[2] > 0) {
				for (i = 0; i < engineVector[1].length; i++) {
					thrust += engineVector[1][i][1];
				}
			}
			if (engineVector[2].length > 0 && fuelArray[3] > 0) {
				for (i = 0; i < engineVector[2].length; i++) {
					thrust += engineVector[2][i][1];
				}
			}
			return thrust;
		}
		
		private function _getDrag(airDensity0:Number, cd:Number, SectionalArea:Number, surfaceVelocity:Number, atmFactor:Number, vR:Number, vT:Number):Array {
			//coarse approximation to have a simulated density close to the real Kerbin's density
			//vT must be the tangential velocity in m/s (not in rad/s)
			//relative to the velocity vector direction (ignore consequence for drag between the velocity vector and ship alignement)
			//ignore skin friction
			var fDrag:Number = - 0.5 * airDensity0 * atmFactor * cd * SectionalArea / 1000;
			var airRelativeVT:Number = vT - surfaceVelocity;
			var temp:Number = Math.sqrt(airRelativeVT * airRelativeVT + vR * vR);
			return [fDrag * temp * vR, fDrag * temp * airRelativeVT];
		}
		
		private function _coarseIterativeApoasis(dt:Number, pR:Number, vR:Number, vT:Number, mass:Number, GM:Number, atmArray:Array):Array {
			//atmArray : [airDensity0, cd, SectionalArea, surfaceVelocity, radius, scaleH]
			var fDrag:Array = new Array();
			var aR:Number, aT:Number, temp:Number, loop:Boolean = true, t:Number = 0;
			dt = dt * 45;
			while (loop) {
				if (atmArray[0] > 0) {
					temp = Math.exp((atmArray[4] - pR) / atmArray[5]);
					fDrag = _getDrag(atmArray[0], atmArray[1],atmArray[2], atmArray[3], temp, vR, vT * pR);
					aR = fDrag[0] / mass - GM / (pR * pR) + pR * vT * vT; //r_dotdot
					aT = (fDrag[1] / mass - 2 * vR * vT) / pR; //theta_dotdot
				}else {
					aR = - GM / (pR * pR) + pR * vT * vT; //r_dotdot
					aT = -2 * vR * vT / pR; //theta_dotdot
				}
				temp = vR;
				vR += aR * dt;
				vT += aT * dt;
				pR += vR * dt;
				t += dt;
				
				if (temp >= 0 && vR <= 0) loop = false; 
			}
			return [t, pR, vT];
		}
		
		private function _getTBurn(dt:Number, dV:Number, payload:Number, engineVector:Vector.<Array>, fuelArray:Array, index:int):Number {
			var aT:Number = 0, vT:Number = 0, t:Number = 0, i:int, temp:Number, fuelConsumption:Number, thrust:Number, massFuel:Number, oldMassFuel:Number;
			//clone the array to not overwrite data
			var fArray:Array = new Array(fuelArray[0], fuelArray[1], fuelArray[2], fuelArray[3], fuelArray[4]), id:int = new int(index);
			var engine:Vector.<Array> = GlobalFunctions.cloneVecArray(engineVector);
			var sumA:Number = 0, factor:Number = dt / Constantes.ISPg0, aTArray:Array = new Array();
			massFuel = fArray[0] + fArray[1] + fArray[2] + fArray[3] + fArray[4];
			var initialMass:Number = payload + massFuel;
			aTArray[0] = 0;
			while (true) {
				t += dt;
				//If there's some fuel left then compute thrust force
				thrust = 0;
				if (massFuel > 0) {
					oldMassFuel = fArray[0] + fArray[1] + fArray[2] + fArray[3] + fArray[4];
					if (engine[0].length > 0 && fArray[0] > 0 && fArray[1] > 0) {
						for (i = 0; i < engine[0].length; i++) {
							//ratio of 11 / 9 for LOX / LF
							//fuelConsumption is metric tons per dt (iteration step) of liquid fuel
							//check if fuel consumption atm and vac are different, if so then add atmFactor for transition
							fuelConsumption = engine[0][i][1] / engine[0][i][3] * factor;
							fArray[0] -= fuelConsumption * 11 / 20;
							fArray[1] -= fuelConsumption * 9 / 20;
							temp = 1;
							if (fArray[0] < 0) {temp = 1 + fArray[0] / (fuelConsumption * 11 / 20), fArray[1] = 0; }
							else if (fArray[1] < 0) {temp = 1 + fArray[1] / (fuelConsumption * 9 / 20), fArray[0] = 0; }
							thrust += temp * engine[0][i][1];
						}
					}
					if (engine[3].length > 0 && fArray[4] > 0) {
						for (i = 0; i < engine[3].length; i++) {
							fuelConsumption = engine[3][i][1] / engine[3][i][3] * factor;
							if (engine[3][i][4] > 0) {
								engine[3][i][4] -= fuelConsumption;
								fArray[4] -= fuelConsumption;
								temp = 1;
								if (engine[3][i][4] < 0) {
									temp = 1 + engine[3][i][4] / fuelConsumption;
									fArray[4] -= engine[3][i][4];
								}
								thrust += engine[3][i][1];
							}
						}
					}
					if (engine[1].length > 0 && fArray[2] > 0) {
						for (i = 0; i < engine[1].length; i++) {
							//fuelConsumption is metric tons per dt (iteration step) of fuel
							fuelConsumption = engine[1][i][1] / engine[1][i][3] * factor;
							fArray[2] -= fuelConsumption;
							temp = 1;
							if (fArray[2] < 0) temp = 1 + fArray[2] / fuelConsumption;
							thrust += temp * engine[1][i][1];
						}
					}
					if (engine[2].length > 0 && fArray[3] > 0) {
						for (i = 0; i < engine[2].length; i++) {
							//fuelConsumption is metric tons per dt (iteration step) of fuel
							fuelConsumption = engine[2][i][1] / engine[2][i][3] * factor;
							fArray[3] -= fuelConsumption;
							temp = 1;
							if (fArray[3] < 0) temp = 1 + fArray[3] / fuelConsumption;
							thrust += temp * engine[2][i][1];
						}
					}
					massFuel = fArray[0] + fArray[1] + fArray[2] +fArray[3] + fArray[4];
				}
				if(id > 0 && massFuel <= 0) {
					id--;
					payload = _getPayload(id, _parameters[id]);
					fArray = _getFuel(_parameters[id]);
					engine = _getEngines(id);
					massFuel = oldMassFuel = fArray[0] + fArray[1] + fArray[2] +fArray[3] + fArray[4];
				}
				
				aT = thrust / (payload + massFuel);
				vT += aT * dt;
				aTArray[aTArray.length] = aT;
				sumA += aT;
				if (dV != 0) {
					if (vT > dV) {
						temp = GlobalFunctions.medianBurnPoint(aTArray, sumA);
						trace("Predicted median burn time : " + (temp * dt), "Predicted total burn time : " + t);
						return temp * dt;
					}else if (id == 0 && massFuel <= 0) {
						temp = GlobalFunctions.medianBurnPoint(aTArray, sumA);
						trace("Not enough fuel to achieved the required dV");
						trace("Predicted median burn time : " + (i * dt), "Predicted total burn time : " + t);
						return temp * dt;
					}
				}
				else {
					if (id == 0 && massFuel <= 0) {
						trace("Velocity remaining in vessel : " + vT);
						return vT;
					}
				}
			}
			trace("Something is wrong with getTBurn");
			return 0;
		}
		
		public function startSimulation(stagesData:Object, pR0:Number, vR0:Number, vT0:Number, thrustAngleStart:Number, thrustAngleEnd:Number , pGT0:Number, pGT90:Number, safeAtmDistance:Number, preBurnFactor:Number):void {
			var preBurnFactor:Number = preBurnFactor / 100 + 1;
			_parameters = stagesData;
			var from:String, to:String, partIndex:String, part:Array;
			
			//add links to _parameters
			for (from in stagesData.links) {
				for (to in stagesData.links[from]) {
					for (partIndex in from, to, stagesData.links[from][to]) {
						part = new Array(stagesData[to][partIndex]);
						//linked parts don't bring mass but thrust and ISP!
						part[3] = 0, part[4] = 0, part[5] = 0, part[6] = 0, part[7] = 0, part[8] = 0;
						_parameters[from].push(stagesData[to][partIndex]);
					}
				}
			}
			
			//define starting stage
			var index:int = GlobalVariables.activeStage, quantity:int = 0, type:int;
			if (_parameters[index] == null) index--;
			var activeStage:Vector.<Array> = _parameters[index];
			//calcul des masses de carburant * fuel_factor
			var payload:Number, fuelArray:Array;
			//Vector for engines [LOX, LF, Mono, Xe, SRB /w fuel]
			var engineVector:Vector.<Array>;
			//define reference planet [label, g0, GM constant, planet radius (m), atmosphere limit (m), scale height, density at ground ]
			var planetData:Array = Constantes[_parameters["extra"+String(index)][4]];
			//set starting data ... tips : Global function to sum Array for later : GlobalFunctions.sumArray();
			payload = _getPayload(index, activeStage);
			fuelArray = _getFuel(activeStage);
			engineVector = _getEngines(index);
			//set starting environnement (R:radial, T:tangential), thrustAngle = 0 : oriented in R axis (in degrees)
			var pR:Number, pT:Number = 0, vR:Number = vR0, vT:Number, thrustAngle:Number = thrustAngleStart * Math.PI / 180, aR:Number = 0, aT:Number = 0;
			var cd:Number = _parameters["extra" + String(index)][2], area:Number = _parameters["extra" + String(index)][3];
			//user input starting altitude, velocity (sideral rotational speed to implement) and thrustAngle - function input : pR0, vR0, vT0, thrustAngle0, pGT0, pGT90
			
			var dt:Number = 0.01, t:Number = 0, i:int; //pas de simulation en seconde
			
			//planet parameters
			var GM:Number = planetData[2], radius:Number = planetData[3];
			var scaleH:Number = planetData[6], airDensity0:Number = planetData[7], surfaceVelocity:Number = planetData[4], safeLimit:Number = planetData[5];
			
			//starting parameters
			if (isNaN(pR0) || isNaN(vR0) || isNaN(vT0) || isNaN(thrustAngleStart) || isNaN(thrustAngleEnd) || isNaN(pGT0) || isNaN(pGT90)) {
				Log.setText = "One or many starting parameters are not numbers - " , EventManager.dispatchEvent(new Event('updateLog'));
			}
				
			pGT0 = pGT0 * 1000 + radius;
			pGT90 = pGT90 * 1000 + radius;
			
			pR = pR0 + radius;
			vT = vT0 / pR;
			massFuel = GlobalFunctions.sumArray(fuelArray);
			
			
			//declaration of watchArray value for graph
			var watchArray:Array = new Array();
			watchArray[0] = new Array(); //t
			watchArray[0][0] = t;
			watchArray[1] = new Array(); //pR
			watchArray[1][0] = pR0 / 1000;
			
			//extraArray is points of interest format : ["title:String","xref on graph:Number","yref on graph:Number","label:String","value:Number", "units:String","label2:String","value2:Number", "units2:String", ...]
			var extraArray:Array = new Array();
			extraArray[0] = new Array(); //max-Q
			extraArray[0] = ["Max-Q", 0, 0, "Drag", 0, "kN"]
			extraArray[1] = new Array(); //ascent burn
			extraArray[1] = ["End of Ascent Burn", 0, 0, "Velocity", 0, "m/s"]
			
			var displayArray:Array = new Array();
			displayArray[0] = "Do not reach minimal altitude";
			displayArray[1] = 0; //Apoapsis
			displayArray[2] = 0; //Periapsis
			
			var destageArray:Array = new Array();
			
			//temp var to speed up some calculation && condition variables
			var fDrag:Array = [0,0], massFuel:Number, airDensity:Number, atmFactor:Number = 0, thrust:Number, fuelConsumption:Number, oldMassFuel:Number;
			var hasAtm:Boolean, idleMode:Boolean, loop:Boolean = true, condition1:Boolean, condition2:Boolean, isCIMode:Boolean, isFinalBurnMode:Boolean, isOOF:Boolean, isSRBActive:Boolean;
			var vR_old:Number = 0, temp:Number, temp2:Number, temp3:Number, airRelativeVT:Number, tempArray:Array, pSafeLimit:Number = radius + safeLimit, pOrbitalLimit:Number = radius + safeLimit + safeAtmDistance * 1000, totalThrust:Number = 0, dtBurn:Number;
			var period:Number = radius * Math.PI * 2 / Math.sqrt(GM / radius) * 5, tBurn:Number, factor:Number = dt / Constantes.ISPg0;
			var counter:int = 0;
			while (loop) {
				t += dt;
				counter++;
				thrust = 0;
				
				//If planet has air then compute drag
				if (airDensity0 > 0 && pR < pSafeLimit) {
					//coarse approximation to have a simulated density close to the real Kerbin's density
					atmFactor = Math.exp((radius - pR) / scaleH);
					if(fDrag != null) temp = fDrag[0] * fDrag[0] + fDrag[1] * fDrag[1];
					fDrag = _getDrag(airDensity0, cd, area, surfaceVelocity, atmFactor, vR, vT * pR);
					if (fDrag[0] * fDrag[0] + fDrag[1] * fDrag[1] < temp) {
						if (extraArray[0][4] * extraArray[0][4] < temp) extraArray[0] = ["MAX-Q", t, (pR - radius) / 1000, "Drag force", Math.sqrt(temp), "kN"];
					}
				}else if (pR >= pSafeLimit && atmFactor > 0) {fDrag[0] = 0, fDrag[1] = 0, atmFactor = 0; }
				
				//no thrust condition && idleMode
				if(!isOOF) {
					if(!isFinalBurnMode) {
						if (pR > radius + safeLimit * 0.2) {
							if (isCIMode) {
								//atmArray : [airDensity0, cd, SectionalArea, surfaceVelocity]
								tempArray = _coarseIterativeApoasis(dt, pR, vR, vT, payload + massFuel, GM, [airDensity0, cd, area, surfaceVelocity, radius, scaleH]);
								
								if (tempArray[1] < pOrbitalLimit) {
									idleMode = false;
								}else {
									extraArray[1] = ["End of Ascent Burn", t, (pR - radius) / 1000, "Velocity", Math.sqrt(vR * vR + vT * vT * pR * pR), "m/s"];
									displayArray[0] = "Reached specified orbit";
									trace("Predicted Apoapsis at time (s) : " + (t + tempArray[0]) + ", distance (m) : " + tempArray[1] + ", vT (rad/s) : " + tempArray[2]);
									dtBurn = -_getTBurn(dt, Math.sqrt(GM / tempArray[1]) - tempArray[2] * tempArray[1], payload, engineVector, fuelArray, index) * preBurnFactor;
									tBurn = t + tempArray[0] + dtBurn;
									trace("Setting burn time at (s) : " + tBurn);
									idleMode = true;
									isFinalBurnMode = true;
								}
							}else if (vR * vR + vT * vT * pR * pR - 2 * (pOrbitalLimit - pR) * GM / (pR * pOrbitalLimit) > 0) isCIMode = true;
						}
					}else {
						if (pR > radius + safeLimit * 0.45  && isFinalBurnMode) {
							if (t > tBurn) idleMode = false;
							if (!idleMode) {
								if (vT * pR * vT * pR >= GM * (2 / pR - 2 / (pR + pOrbitalLimit))) {
									idleMode = true, displayArray[0] = "Orbital speed achieved";
									if (extraArray[3] == null && extraArray[2] != null) {
										extraArray[3] = new Array();
										extraArray[3] = ["End of Orbital Burn", t, (pR - radius) / 1000 , "Start of burn vs Ap", dtBurn, "s", "Total burn time", t - tBurn, "s", "Angular gain", pT * 180 / Math.PI, "°"]
									}
								}
							}
						}
					}
				}

				//If there's some fuel left then compute thrust force
				if (massFuel > 0) {
					oldMassFuel = fuelArray[0] + fuelArray[1] + fuelArray[2] + fuelArray[3] + fuelArray[4];
					
					if (pR >= pGT0 && pR <= pGT90) {
						thrustAngle = thrustAngleStart - (thrustAngleStart - thrustAngleEnd) * (pR - pGT0) / (pGT90 - pGT0);
						thrustAngle *= Math.PI / 180;
					}else if (pR > pGT90) {
						if (thrustAngleEnd > 0) thrustAngle = Math.PI / 2;
						if (thrustAngleEnd < 0) thrustAngle = -Math.PI / 2;
					}else if (pR >= pOrbitalLimit) {
						temp = vR / Math.sqrt(vR * vR + vT * vT);
						if (thrustAngleEnd > 0) thrustAngle = Math.PI / 2 - temp;
						if (thrustAngleEnd < 0) thrustAngle = -Math.PI / 2 + temp;
					}
					
					if(!idleMode) {
						if (engineVector[0].length > 0 && fuelArray[0] > 0 && fuelArray[1] > 0) {
							for (i = 0; i < engineVector[0].length; i++) {
								//ratio of 11 / 9 for LOX / LF
								//fuelConsumption is metric tons per dt (iteration step) of liquid fuel
								//check if fuel consumption atm and vac are different, if so then add atmFactor for transition
								temp = engineVector[0][i][1] / engineVector[0][i][3];
								fuelConsumption = (temp + (engineVector[0][i][0] / engineVector[0][i][2] - temp) * atmFactor) * factor;
								fuelArray[0] -= fuelConsumption * 11 / 20;
								fuelArray[1] -= fuelConsumption * 9 / 20;
								temp = 1;
								if (fuelArray[0] < 0) temp = 1 + fuelArray[0] / (fuelConsumption * 11 / 20);
								else if (fuelArray[1] < 0) temp = 1 + fuelArray[1] / (fuelConsumption * 9 / 20);
								thrust += temp * (engineVector[0][i][1] + (engineVector[0][i][0] - engineVector[0][i][1]) * atmFactor);
							}
						}
						if (engineVector[1].length > 0 && fuelArray[2] > 0) {
							for (i = 0; i < engineVector[1].length; i++) {
								//fuelConsumption is metric tons per dt (iteration step) of fuel
								temp = engineVector[1][i][1] / engineVector[1][i][3];
								fuelConsumption = (temp + (engineVector[1][i][0] / engineVector[1][i][2] - temp) * atmFactor) * factor;
								fuelArray[2] -= fuelConsumption;
								temp = 1;
								if (fuelArray[2] < 0) temp = 1 + fuelArray[2] / fuelConsumption;
								thrust += temp * (engineVector[1][i][1] + (engineVector[1][i][0] - engineVector[1][i][1]) * atmFactor);
							}
						}
						if (engineVector[2].length > 0 && fuelArray[3] > 0) {
							for (i = 0; i < engineVector[2].length; i++) {
								//fuelConsumption is metric tons per dt (iteration step) of fuel
								temp = engineVector[2][i][1] / engineVector[2][i][3];
								fuelConsumption = (temp + (engineVector[2][i][0] / engineVector[2][i][2] - temp) * atmFactor) * factor;
								fuelArray[3] -= fuelConsumption;
								temp = 1;
								if (fuelArray[3] < 0) temp = 1 + fuelArray[3] / fuelConsumption;
								thrust += temp * (engineVector[2][i][1] + (engineVector[2][i][0] - engineVector[2][i][1]) * atmFactor);
							}
						}
					}
					if(!idleMode || isSRBActive) {
						if (engineVector[3].length > 0 && fuelArray[4] > 0) {
							isSRBActive = true;
							for (i = 0; i < engineVector[3].length; i++) {
								temp = engineVector[3][i][1] / engineVector[3][i][3];
								fuelConsumption = (temp + (engineVector[3][i][0] / engineVector[3][i][2] - temp) * atmFactor) * factor;
								if (engineVector[3][i][4] > 0) {
									engineVector[3][i][4] -= fuelConsumption;
									fuelArray[4] -= fuelConsumption;
									temp = 1;
									if (engineVector[3][i][4] < 0) {
										temp = 1 + engineVector[3][i][4] / fuelConsumption;
										fuelArray[4] -= engineVector[3][i][4];
									}
									thrust += temp * (engineVector[3][i][1] + (engineVector[3][i][0] - engineVector[3][i][1]) * atmFactor);
								}
							}
						}else isSRBActive = false;
					}
					
					massFuel = fuelArray[0] + fuelArray[1] + fuelArray[2] + fuelArray[3] + fuelArray[4];
				}
				
				if (index > 0 && massFuel <= 0) {
					trace("Out of fuel for stage " + String(index) + " at t (s) : " + String(t));
					temp = destageArray.length, destageArray[temp] = new Array(), destageArray[temp] = ["End of Stage", t, (pR - radius) / 1000 , "Stage", index, "no"];
					index--;
					activeStage = _parameters[index];
					payload = _getPayload(index, activeStage);
					fuelArray = _getFuel(activeStage);
					engineVector = _getEngines(index);
					massFuel = oldMassFuel = fuelArray[0] + fuelArray[1] + fuelArray[2] + fuelArray[3] + fuelArray[4];
					cd = _parameters["extra" + String(index)][2];
					area = _parameters["extra" + String(index)][3];
					if (isFinalBurnMode && idleMode && isSRBActive) {
						tempArray = _coarseIterativeApoasis(dt, pR, vR, vT, payload + massFuel, GM, [airDensity0, cd, area, surfaceVelocity, radius, scaleH]);
						dtBurn = -_getTBurn(dt, Math.sqrt(GM / tempArray[1]) - tempArray[2] * tempArray[1], payload, engineVector, fuelArray, index) * preBurnFactor;
						tBurn = t + tempArray[0] + dtBurn;
						trace("New tBurn after SRB burn : " + tBurn);
					}
					isSRBActive = false;
					trace("New fuel Array : " + fuelArray);
				} else if (index <= 0 && massFuel <= 0) isOOF = true;

				temp = aR, temp2 = aT;
				if (thrust != 0) {
					aR = (thrust * Math.cos(thrustAngle) + fDrag[0]) / (payload + (oldMassFuel + massFuel) / 2) - GM / (pR * pR) + pR * vT * vT; //r_dotdot
					aT = ((thrust * Math.sin(thrustAngle) + fDrag[1]) / (payload + (oldMassFuel + massFuel) / 2) - 2 * vR * vT) / pR; //theta_dotdot
				}else if(atmFactor > 0) {
					aR = fDrag[0] / (payload + (oldMassFuel + massFuel) / 2) - GM / (pR * pR) + pR * vT * vT; //r_dotdot
					aT = (fDrag[1] / (payload + (oldMassFuel + massFuel) / 2) - 2 * vR * vT) / pR; //theta_dotdot
				}else {
					aR = -GM / (pR * pR) + pR * vT * vT; //r_dotdot
					aT = (-2 * vR * vT) / pR; //theta_dotdot
				}
				vR_old = vR, temp3 = vR;
				vR += (temp + aR) / 2  * dt;
				temp = vT;
				vT += (temp2 + aT) / 2  * dt;
				pR += (temp3 + vR) / 2 * dt;
				pT += (temp + vT) / 2  * dt;
				watchArray[0][counter] = t; //s
				watchArray[1][counter] = (pR - radius) / 1000; //km
								
				//end loop condition
				//crash condition
				if (pR < radius) {pR = radius, vR = 0, vT = vT0 / radius, loop = false; displayArray[0] = "Vessel crashed"}
				if (isOOF) displayArray[0] = "Ran out Of fuel"
				if (idleMode && vR_old >= 0 && vR <= 0 && pR > pSafeLimit) {
					displayArray[1] = Math.round((pR - radius) / 100) / 10;
					if (extraArray[4] == null && extraArray[3] != null) {
						extraArray[4] = new Array();
						extraArray[4] = ["Reached Apoapsis", t, (pR - radius) / 1000 , "Mass of fuel rem.", massFuel, "t", "Delta-v rem.", _getTBurn(dt, 0, payload, engineVector, fuelArray, index), "m/s"];
					}
				}
				if (idleMode && vR_old <= 0 && vR >= 0 && pR > pSafeLimit) {
					displayArray[2] = Math.round((pR - radius) / 100) / 10
					if (extraArray[5] == null  && extraArray[3] != null) {
						extraArray[5] = new Array();
						extraArray[5] = ["Reached Periapsis", t, (pR - radius) / 1000 , "Happiness", 100, "%"];
					}
				}
				if (displayArray[2] > safeLimit / 1000 && displayArray[1] > displayArray[2]  && idleMode && loop) {loop = false, displayArray[0] = "Stable orbit achieved"}
				if (t > period) {loop = false, displayArray[0] = "No solution found : vessel adrifted"}
				if (extraArray[2] == null && extraArray[1] != null) if (pR > pSafeLimit) {extraArray[2] = new Array(), extraArray[2] = ["Reached Safe Limit", t, (pSafeLimit - radius) / 1000 , "Velocity", Math.sqrt(vR * vR + vT * vT * pR * pR), "m/s"];}
			}
			trace("max apoapsis (km) : " + GlobalFunctions.max(watchArray[1]));
			trace("max time (s) : " + GlobalFunctions.max(watchArray[0]));
			trace("fuel left (t) : " + fuelArray);
			trace("Apoapsis (km) : " + displayArray[1]);
			trace("Periapsis (km) : " + displayArray[2]);
			_traceResults(["Time (s)","Altitude (km)"], watchArray, extraArray, displayArray, destageArray);
		}
	}
}