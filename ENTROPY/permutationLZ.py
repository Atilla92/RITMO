from itertools import permutations

def permutation_lz_complexity(sequence):
    distinct_permutations = set(permutations(sequence))
    lz_complexity = len(distinct_permutations)
    return lz_complexity

# Example usage
sequence = [1, 2, 3]
lz_complexity = permutation_lz_complexity(sequence)
print("Permutation LZ-complexity:", lz_complexity)


#Feed window of sequence at the time.. 
#Feed permutated signal to LZ complexity. 
