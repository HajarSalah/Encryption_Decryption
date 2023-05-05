option="" #this is the menu option variable
echo "Welcome to Text Message Encryption & Decryption Shell Program."
echo "Please select the letters 'E\e' for encryption or 'D\d' for decryption.."
read option
case "$option" in
e|E)
#Testing for plain file existence
echo "Enter plain text file name, please"
read plainFile
if test -f "$plainFile"; then
   echo "$plainFile exists."
else
   echo "There is no such file exists in the current directory."
   exit 1
fi

#Testing if the plain file contains any non-alphabet characters
while read -r -p  line; do
      if [[ $line =~ [^A-Za-z] ]]; then
         echo "Input file contains non-alphabetical characters."
         exit 1
      fi
done < $plainFile


#needed variables
sum=0
max=0
keyWord=""

while read -r line; do #while loop to iterate over the file line by line
read -r -a array <<< "$line" #storing the line's words in an array neglecting spaces
for word in ${array[@]}; do #a loop to work on each word/element inside the ararray
    while read -n1 char; do #a loop to sum up the values of the word's char
               #echo "$char"
               case "$char" in
                A|a)sum=$(($sum+1));;
                B|b)sum=$(($sum+2));;
                C|c)sum=$(($sum+3));;
                D|d)sum=$(($sum+4));;
                E|e)sum=$(($sum+5));;
                F|f)sum=$(($sum+6));;
                G|g)sum=$(($sum+7));;
                H|h)sum=$(($sum+8));;
                I|i)sum=$(($sum+9));;
                J|j)sum=$(($sum+10));;
                K|k)sum=$(($sum+11));;
                L|l)sum=$(($sum+12));;
                M|m)sum=$(($sum+13));;
                N|n)sum=$(($sum+14));;
                O|o)sum=$(($sum+15));;
                P|p)sum=$(($sum+16));;
                Q|q)sum=$(($sum+17));;
                R|r)sum=$(($sum+18));;
                S|s)sum=$(($sum+19));;
                T|t)sum=$(($sum+20));;
                U|u)sum=$(($sum+21));;
                V|v)sum=$(($sum+22));;
                W|w*)sum=$(($sum+23));;
                X|x)sum=$(($sum+24));;
                Y|y)sum=$(($sum+25));;
                Z|z)sum=$(($sum+26));;
               esac
    done <<< "$word" #passing word/array element
    #printf  "This is the sum of the word %d\n" $sum
        key=$(($sum%256))
    if [ "$sum" -gt "$max" ] #getting the maximum sum that a word can reach
    then
    max=$sum
    keyWord="$word"
    fi
    sum=0
    
done
done < $plainFile #passing the plain file
bkey=$(echo "obase=2;$max" | bc) #convering the key from decimal to binary
printf "key word is "%s" and the key is %.2f\n" $keyWord $max
printf "The binary value of the key is %d\n" $bkey


#files needed for conversion proccess
>ascii.txt #empty the ascii values file
>delim.txt
>delim2.txt
>dAscii.txt
>bAscii.txt
>xor1.txt
>xor2.txt
>xor3.txt


tr ' ' '&' < $plainFile > delim.txt
tr '\12' '@' < delim.txt > delim2.txt
while read -n 1 char; do #read file char by char
printf "%s%d\n" $char  \'$char >> ascii.txt #print each ascii value into the file
done < delim2.txt


#this loop is to get the decimal ascii from the file
while read -n 1 char; do
tr -d '[A-Za-z@&]' < ascii.txt > dAscii.txt #save the decimal values in dAscii.txt
done < ascii.txt


#this loop is to convert decimals to binary ascii
while read decimalAscii; do
binaryAscii=$(echo "obase=2;$decimalAscii" | bc) 
echo "$binaryAscii" >> bAscii.txt #into the binary ascii containment file
done < dAscii.txt #handle the decimal ascii values file


#this loop is to do the XOR evaluation
while read decimalAscii;do
xorVal=$(($decimalAscii ^$max))
echo "$xorVal" >> xor1.txt
done < dAscii.txt

#this loop is to convert decimals to binary after decimal xor
while read decimalXor; do
binaryXor=$(echo "obase=2;$decimalXor" | bc) 
echo "$binaryXor" >> xor2.txt #into the binary xor containment file
done < xor1.txt #handle the decimal xor values file


#to count num of digits so if it was less than 8 we need to prepend to represent in 8-bits
count=0
while read -r line; do #read line by line
count=${#line} #a command to count num of char in a string and save is a variable
         while [ $count != 8 ]; do #a loop to prepend zeroes
         line="0$line" #summing two strings
         count=$(($count+1)) #increment
         done
         if [ $count = 8 ]; then
                  echo "$line" >> xor3.txt #save the 8-bit representation in a new file
         fi
count=0
done < xor2.txt


echo "Enter the cipher text file name, please!"
read encrypted
> $encrypted
#this is the 4 bit swap loop
while read -r line; do
echo "${line:(-4)}${line:0:4}" >> $encrypted #swaping technique
done < xor3.txt


countKey=${#bkey}
while [ $countKey != 8 ]; do #a loop to prepend zeroes
        bkey="0$bkey" #summing two strings
         countKey=$(($countKey+1)) #increment
         done
      if [ $countKey == 8 ]; then
        echo "${bkey:(-4)}${bkey:0:4}" >> $encrypted # key swaping technique 
       fi


;;

#Done For Encryption

d|D)
echo "Enter cipher file name."
read cipher
if test -f "$cipher"; then
   echo "$cipher exists."
   else
   echo "There is no such file exists in the current directory."
   exit 1
fi
:>infile.txt
cp $cipher infile.txt
:>temp.txt
:>semiFinal.txt
:>EncSwapped.txt 
:>swapped.txt 
:>Final.txt
:>invdDelim.txt

Keydec=""
line1=$(tail -n1 infile.txt)
Keydec=${line1:(-4)}${line1:0:4}
Dkey=$(echo "$((2#$Keydec))") #convert the key from binary to decimal
printf "The key value in binary is (%s) and decimal is (%s)\n" $Keydec $Dkey

#To delete the last line of the file "infile.txt"
sed '$d' infile.txt > temp.txt && mv temp.txt infile.txt

#To swap 4x4 the binary of chars
while read -r l; do
echo "${l:(-4)}${l:0:4}" >> swapped.txt 
done < infile.txt

#this loop is to convert binary to decimal 
while read swap; do
bin2dec=$(echo "$((2#$swap))") #convert the swapped from binary to decimal
echo "$bin2dec" >> EncSwapped.txt 
done < swapped.txt 


#this loop is to do the XOR evaluation
while read deciSwap;do
decXKey=$(($deciSwap ^$Dkey))
echo "$decXKey" >> semiFinal.txt
done < EncSwapped.txt 

#To get the char from ascii
while read a; do
        echo "$a" | awk '{ printf("%c",$0); }' >> Final.txt

done < semiFinal.txt

echo "Enter the decrypted (plain text) file name."
read output
tr '&' ' ' < Final.txt > invDelim.txt
tr '@' '\12' < invDelim.txt > $output
;;

*) 
echo "Please enter a valid input!"
exit 1
esac
