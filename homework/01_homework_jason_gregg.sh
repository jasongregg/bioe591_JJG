###bash script for homework week 1
#Change into the raw_data directory
cd week1;
#Create three subdirectories called:
mkdir fastq/
mkdir fasta/
mkdir metadata/
#Move files into these directories based on file extension:
mv *.fastq.gz fastq/
mv *.fasta fasta/
mv *.csv metadata/
#Count how many files are in each new directory and print to the screen.
echo "File counts:"
echo "fastq/:    $(find fastq -maxdepth 1 -type f | wc -l)"
echo "fasta/:    $(find fasta -maxdepth 1 -type f | wc -l)"
echo "metadata/: $(find metadata -maxdepth 1 -type f | wc -l)"