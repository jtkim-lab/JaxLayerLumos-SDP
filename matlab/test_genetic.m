% Genetic Algorithm to Minimize Reflection for Three-Layer Configuration 
clear all
close all
clc

% Parameters
numGenerations = 10; % Number of generations
popSize = 10; % Population size
mutationRate = 0.1; % Mutation rate

% Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)
f = 0.1:0.01:1; 
numFrequencies = length(f);
f_Hz = f * 1e9; % Frequency in Hz

% Speed of light in m/s
c = 3e8;

% Wavelength in meters
wavelength = c ./ f_Hz;

% Boundaries for thicknesses of layers [in mm]
minThickness = 0.1; % Minimum thickness (mm)
maxThickness = 5;   % Maximum thickness (mm)

% Material options for each layer (indices corresponding to material properties in M_epsr and M_mur)
materialOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
numMaterials = length(materialOptions);

% Relative permittivity and permeability matrices 
M_epsr = zeros(16, numFrequencies);
M_mur = zeros(16, numFrequencies);

% Fill constant values for permittivity (epsr)
M_epsr(1:5, :) = repmat([10 50 15 15 15]', 1, numFrequencies);
M_epsr(9:16, :) = 15;

% Frequency-dependent permittivity values for materials 6 to 8
M_epsr(6, :) = 5 ./ (f.^0.861) - 1i * (8 ./ (f.^0.569));
M_epsr(7, :) = 8 ./ (f.^0.778) - 1i * (10 ./ (f.^0.682));
M_epsr(8, :) = 10 ./ (f.^0.778) - 1i * (6 ./ (f.^0.861));

% Fill constant values for permeability (mur)
M_mur(1:2, :) = 1;
M_mur(6:8, :) = 1;

% Frequency-dependent permeability for materials 3 to 5
M_mur(3, :) = 5 ./ (f.^0.974) - 1i * (10 ./ (f.^0.961));
M_mur(4, :) = 3 ./ (f.^1) - 1i * (15 ./ (f.^0.957));
M_mur(5, :) = 7 ./ (f.^1) - 1i * (12 ./ (f.^1));

% Frequency-dependent permeability for materials 9 to 16
M_mur(9, :) = (35 * (0.8^2)) ./ (f.^2 + 0.8^2) - 1i * (35 * 0.8 * f) ./ (f.^2 + 0.8^2);
M_mur(10, :) = (35 * (0.5^2)) ./ (f.^2 + 0.5^2) - 1i * (35 * 0.5 * f) ./ (f.^2 + 0.5^2);
M_mur(11, :) = (30 * (1^2)) ./ (f.^2 + 1^2) - 1i * (30 * f) ./ (f.^2 + 1^2);
M_mur(12, :) = (18 * (0.5^2)) ./ (f.^2 + 0.5^2) - 1i * (18 * 0.5 * f) ./ (f.^2 + 0.5^2);
M_mur(13, :) = (20 * (1.5^2)) ./ (f.^2 + 1.5^2) - 1i * (20 * 1.5 * f) ./ (f.^2 + 1.5^2);
M_mur(14, :) = (30 * (2.5^2)) ./ (f.^2 + 2.5^2) - 1i * (30 * 2.5 * f) ./ (f.^2 + 2.5^2);
M_mur(15, :) = (30 * (2^2)) ./ (f.^2 + 2^2) - 1i * (30 * 2 * f) ./ (f.^2 + 2^2);
M_mur(16, :) = (25 * (3.5^2)) ./ (f.^2 + 3.5^2) - 1i * (25 * 3.5 * f) ./ (f.^2 + 3.5^2);

% Generate initial population (random selection of thickness and material index)
population = [rand(popSize, 3) * (maxThickness - minThickness) + minThickness, ...
              randi(numMaterials, popSize, 3)];

% Main loop for genetic algorithm
for gen = 1:numGenerations
    fitness = zeros(popSize, 1);
    
    % Evaluate the fitness of each individual
    for i = 1:popSize
        thickness = population(i, 1:3);
        mat_selection = materialOptions(population(i, 4:6));
        
        epsr = [ones(1, numFrequencies); M_epsr(mat_selection, :); ones(1, numFrequencies)];
        mur = [ones(1, numFrequencies); M_mur(mat_selection, :); ones(1, numFrequencies)];
        
        reflection = zeros(1, numFrequencies);
        for j = 1:numFrequencies
            [rSlab_TE_abs, ~] = RMultiSlab(3, 0, epsr(:, j), mur(:, j), f(j), thickness);
            reflection(j) = rSlab_TE_abs(4); % Reflection for three layers plus air
        end
        
        fitness(i) = min(abs(10 * log10(reflection))); 
    end
    
    % Output current generation and fitness
    fprintf('Generation %d:\n', gen);
    for i = 1:popSize
        fprintf('  Individual %d: Thicknesses = [%.4f, %.4f, %.4f] mm, Materials = [%d, %d, %d], Fitness = %.4f\n', ...
                i, population(i, 1:3), population(i, 4:6), fitness(i));
    end
    
    % Selection (tournament selection)
    [~, sortedIdx] = sort(fitness);
    population = population(sortedIdx, :);
    
    % Crossover (single-point crossover)
    for i = 1:2:popSize-1
        crossoverPoint = randi(6);
        temp = population(i, crossoverPoint:end);
        population(i, crossoverPoint:end) = population(i+1, crossoverPoint:end);
        population(i+1, crossoverPoint:end) = temp;
    end
    
    % Mutation (random mutation based on mutation rate)
    for i = 1:popSize
        if rand < mutationRate
            mutationPoint = randi(6);
            if mutationPoint <= 3
                population(i, mutationPoint) = rand * (maxThickness - minThickness) + minThickness;
            else
                population(i, mutationPoint) = randi(numMaterials);
            end
        end
    end
end

% Best individual after evolution
bestIndividual = population(1, :);

% Display the results
bestThickness = bestIndividual(1:3);
bestMaterials = materialOptions(bestIndividual(4:6));
bestFitness = fitness(1);

fprintf('Best Thicknesses: %.4f mm, %.4f mm, %.4f mm\n', bestThickness);
fprintf('Best Materials: %d, %d, %d\n', bestMaterials);
fprintf('Best Fitness: %.4f\n', bestFitness);

% Plot reflection for best individual
epsr = [ones(1, numFrequencies); M_epsr(bestMaterials, :); ones(1, numFrequencies)];
mur = [ones(1, numFrequencies); M_mur(bestMaterials, :); ones(1, numFrequencies)];
reflection = zeros(1, numFrequencies);
for j = 1:numFrequencies
    [rSlab_TE_abs, ~] = RMultiSlab(3, 0, epsr(:, j), mur(:, j), f(j), bestThickness);
    reflection(j) = rSlab_TE_abs(4);
end

reflection_dB = 10 * log10(reflection);
semilogx(f, reflection_dB, 'r', 'LineWidth', 2.5);
title('Genetic Algorithm Optimization of RAM Structure')
xlabel('Frequency (GHz)')
ylabel('Reflection in dB')
grid on
 