#! /bin/bash

#SBATCH --job-name="PythiaGen"
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=1
#SBATCH --partition=std
#SBATCH --time=24:00:00
#SBATCH --array=1-110
#SBATCH --output=/rstorage/alice/AnalysisResults/ang/slurm-%A_%a.out

# Center of mass energy in GeV
ECM=5020

# Number of events per pT-hat bin (for statistics)
NEV_DESIRED=1000000

# Lower edges of the pT-hat bins
PTHAT_BINS=(9 12 16 21 28 36 45 57 70 85 100)
echo "Number of pT-hat bins: ${#PTHAT_BINS[@]}"

# Currently we have 8 nodes * 20 cores active
NCORES=110
NEV_PER_JOB=$(( $NEV_DESIRED * ${#PTHAT_BINS[@]} / $NCORES ))
echo "Number of events per job: $NEV_PER_JOB"
NCORES_PER_BIN=$(( $NCORES / ${#PTHAT_BINS[@]} ))
echo "Number of cores per pT-hat bin: $NCORES_PER_BIN"

BIN=$(( ($SLURM_ARRAY_TASK_ID - 1) / $NCORES_PER_BIN + 1))
CORE_IN_BIN=$(( ($SLURM_ARRAY_TASK_ID - 1) % $NCORES_PER_BIN + 1))
PTHAT_MIN=${PTHAT_BINS[$(( $BIN - 1 ))]}
if [ $BIN -lt ${#PTHAT_BINS[@]} ]; then
    USE_PTHAT_MAX=true
	PTHAT_MAX=${PTHAT_BINS[$BIN]}
	echo "Calculating bin $BIN (pThat=[$PTHAT_MIN,$PTHAT_MAX]) with core number $CORE_IN_BIN"
else
    USE_PTHAT_MAX=false
	echo "Calculating bin $BIN (pThat_min=$PTHAT_MIN) with core number $CORE_IN_BIN"
fi

SEED=$(( ($CORE_IN_BIN - 1) * NEV_PER_JOB + 1111 ))

# Do the PYTHIA simulation & matching
OUTDIR="/rstorage/alice/AnalysisResults/ang/$SLURM_ARRAY_JOB_ID/$BIN/$CORE_IN_BIN"
mkdir -p $OUTDIR
module use /software/users/ezra/heppy/modules
module load heppy/1.0
module use /software/users/ezra/pyjetty/modules
module load pyjetty/1.0
echo "python is" $(which python)
cd /software/users/ezra/analysis_env/
SCRIPT="/software/users/ezra/pyjetty/pyjetty/alihfjets/dev/hfjet/process/user/hf_EEC/pythia_quark_gluon_ezra.py"
CONFIG="/software/users/ezra/pyjetty/pyjetty/alice_analysis/config/ang/mass_R0.2_ptbin2.yaml"

if $USE_PTHAT_MAX; then
	echo "python $SCRIPT -o $OUTDIR -c $CONFIG --user-seed $SEED --py-pthatmin $PTHAT_MIN --py-ecm $ECM --nev $NEV_PER_JOB --replaceKP 1 --chinitscat 3 --pythiaopts HardQCD:all=on,PhaseSpace:pTHatMax=$PTHAT_MAX"
	python $SCRIPT -o $OUTDIR -c $CONFIG --user-seed $SEED \
		--py-pthatmin $PTHAT_MIN --py-ecm $ECM --nev $NEV_PER_JOB \
		--replaceKP 1 --chinitscat 3 --pythiaopts HardQCD:all=on,PhaseSpace:pTHatMax=$PTHAT_MAX
else
	echo "python $SCRIPT -o $OUTDIR -c $CONFIG --user-seed $SEED --py-pthatmin $PTHAT_MIN --py-ecm $ECM --nev $NEV_PER_JOB --replaceKP 1 --chinitscat 3 --pythiaopts HardQCD:all=on"
	python $SCRIPT -o $OUTDIR -c $CONFIG --user-seed $SEED \
        --py-pthatmin $PTHAT_MIN --py-ecm $ECM --nev $NEV_PER_JOB \
        --replaceKP 1 --chinitscat 3 --pythiaopts HardQCD:all=on
fi
