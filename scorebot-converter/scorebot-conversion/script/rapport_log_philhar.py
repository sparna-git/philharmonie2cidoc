# python
# Ce script génère un tableau en comptant le nombre de messages de Warning dans le fichier de log
# C'est un utilitaire qui n'est pas obligatoire pour la conversion des fichiers,
# il facilite simplement la lecture du fichier de log
# 
# Pour le lancer, il faut :
# - Installer Python
# - python rapport_log_philhar.py <path_du_fichier_de_log.log> <chemin_du_fichier_output.csv> <mot-clé_optionnel>
# 


import os
import sys
import pandas as pd



def read_file(pahtfile):

	MESSAGE=[]
	f = open(pahtfile, "r")
	for r in f:
		if (r.startswith("Warning - ")):
			text = r.split("Warning - ")[1]
			MESSAGE.append(text.rstrip())

	# Sort
	MESSAGE.sort()
	return MESSAGE

def filter_vocabulaires(df):

	df["MIMO"] = df.MESSAGE.str.contains('MIMO')
	df["IAML"] = df.MESSAGE.str.contains('IAML')
	df["NIVEAU"] = df.MESSAGE.str.contains('Niveau')
	df["ROL"] = df.MESSAGE.str.contains('role vocabulary')

	return df

def find_mot_cle(df,keyword : str):
	return df[df.MESSAGE.str.contains(keyword)]


if __name__ == '__main__':

	# read log
	pathFolder = sys.argv[1] # Param 1 - Path to the log file to parse
	outputFile = sys.argv[2] # Param 2 - output file
	try:
		keyword = sys.argv[3] # Param 3 - find a word key
	except Exception as e:
		keyword = None
	

	result_extract = read_file(pathFolder)
	# Dataframe
	df = pd.DataFrame(result_extract,columns =["MESSAGE"])
	df["TOTAL"] = 1 #Default

	# Group by post type
	df_GpoBy =df.groupby("MESSAGE").sum().reset_index()

	if keyword != None:
		# Search by a keyword
		df_result = find_mot_cle(df_GpoBy,keyword)
	else:
		df_result = filter_vocabulaires(df_GpoBy)
	
	if ~df_result.empty:
		# send the result to csv file
		df_result.to_csv(outputFile, header=True,encoding='utf8', sep='|', index=False)