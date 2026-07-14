# General Schematic

The figure below shows the overall architecture of the project. The implemented spiking neural network consists of four input neurons, a 4×2 STPP synaptic array, and two output neurons. Each output neuron is connected to an integrator circuit that generates the corresponding output voltage based on the network activity.
![generalDiagram](schematic.png)

## Pin out 
This project requires six chip pins:

* **VDD**: Power supply
* **GND**: Ground
* **VIN1**: Input voltage
* **VOUT1**: Output voltage 1
* **VOUT2**: Output voltage 2
* **CHECK1**: Test pin for monitoring the synaptic voltage.


According to these requirements, Configuration Block C was selected, as it provides six available pins for the project.
![pinOut](pinout.png)


