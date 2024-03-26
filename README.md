# Codificatore Convoluzionale<br>
## Progetto relativo all'insegnamento "Reti Logiche" di Ingegneria Informatica al Politecnico di Milano. 2022-2023<br>

Si chiede di implementare un modulo HW (descritto in VHDL) che si interfacci con una memoria e che segua la seguente specifica. <br>
 *  Il modulo riceve in ingresso una sequenza continua di W parole, ognuna di 8 bit, e  restituisce in uscita una sequenza continua di Z parole, ognuna da 8 bit. Ognuna delle parole di ingresso viene serializzata; in questo modo viene generato un flusso continuo U da  1 bit. Su questo flusso viene applicato il codice convoluzionale ½ (ogni bit viene codificato con 2 bit) secondo lo schema riportato in figura; questa operazione genera in uscita un  flusso continuo Y. Il flusso Y è ottenuto come concatenamento alternato dei due bit di uscita.
 Utilizzando la notazione riportata in figura, il bit uk genera i bit p1k e p2k che sono poi concatenati per generare un flusso continuo yk (flusso da 1 bit). La sequenza d’uscita Z è la parallelizzazione, su 8 bit, del flusso continuo yk.<br>

 * La lunghezza del flusso U è 8xW mentre la lunghezza del flusso Y è 8xWx2 (Z=2xW).
 Il convolutore è una macchina sequenziale sincrona con un clock globale e un segnale di
 reset con il seguente diagramma degli stati che ha nel suo 00 lo stato iniziale, con uscite in
 ordine P1K, P2K (ogni transizione è annotata come Uk/p1k, p2k).
<br>
Un esempio di funzionamento è il seguente dove il primo bit a sinistra (il più significativo del
 BYTE) è il primo bit seriale da processare:<br>
 * BYTE IN INGRESSO = 10100010 (viene serializzata come 1 al tempo t, 0 al tempo
 t+1, 1 al tempo t+2, 0 al tempo t+3, 0 al tempo t+4, 0 al tempo t+5, 1 la tempo t+6 e 0 al tempo t+7)
<br> 
 Applicando l’algoritmo convoluzionale si ottiene la seguente serie di coppie di bit:<br>
T 0 1 2 3 4 5 6 7<br>
Uk 1 0 1 0 0 0 1 0<br>
P1k 1 0 0 0 1 0 1 0<br>
P2k 1 1 0 1 1 0 1 1<br>
<br>
 Il concatenamento dei valori Pk1 e Pk2 per produrre Z segue il seguente schema: Pk1 al tempo t, Pk2 al tempo t, Pk1 al tempo t+1 Pk2 al tempo t+1, Pk1 al tempo t+2 Pk2 al tempo t+2, … cioè <br>
 Z:  1 1 0 1 0 0 0 1 1 1 0 0 1 1 0 1
<br>BYTE IN USCITA = 11010001  e 11001101
 <br>NOTA: ogni byte di ingresso W ne genera due in uscita (Z)
 
 # Dati
 Il modulo da implementare deve leggere la sequenza da codificare da una memoria con indirizzamento al Byte in cui è memorizzato; ogni singola parola di memoria è un byte. La sequenza di byte è trasformata nella sequenza di bit U da elaborare. La quantità di parole W da codificare è memorizzata nell’indirizzo 0; il primo byte della sequenza W è memorizzato all’indirizzo 1. Lo stream di uscita Z deve essere memorizzato a partire dall’indirizzo 1000 (mille). La dimensione massima della sequenza di ingresso è 255 byte.
<br>
 1. Il modulo partirà nella elaborazione quando un segnale START in ingresso verrà portato a 1. Il segnale di START rimarrà alto fino a che il segnale di DONE non verrà  portato alto; Al termine della computazione (e una volta scritto il risultato in memoria),  il modulo da progettare deve alzare (portare a 1) il segnale DONE che notifica la fine dell’elaborazione. Il segnale DONE deve rimanere alto fino a che il segnale di START non è riportato a 0. Un nuovo segnale start non può essere dato fin tanto che DONE non è stato riportato a zero. Se a questo punto viene rialzato il segnale di START, il  modulo dovrà ripartire con la fase di codifica.<br>
 2. Il modulo deve essere dunque progettato per poter codificare più flussi uno dopo l’altro. Ad ogni nuova elaborazione (quando START viene riportato alto a seguito del DONE basso), il convolutore viene portato nel suo stato di iniziale 00 (che è anche quello di reset). La quantità di parole da codificare sarà sempre memorizzata all’indirizzo 0 e l’uscita deve essere sempre memorizzata a partire dall’indirizzo 1000. <br>
 3. Il modulo deve essere progettato considerando che prima della prima codifica verrà sempre dato il RESET al modulo. Invece, come descritto nel protocollo precedente, una seconda elaborazione non dovrà attendere il reset del modulo ma solo la terminazione della elaborazione.
  
# Interfaccia del Componente
 Il componente da descrivere deve avere la seguente interfaccia.
 entity project_reti_logiche is<br>
 port (<br>
 i_clk     <br>
i_rst     <br>
: in std_logic;<br>
 : in std_logic;<br>
 i_start   : in std_logic;<br>
 i_data    <br>
: in std_logic_vector(7 downto 0);<br>
 o_address : out std_logic_vector(15 downto 0);<br>
 o_done    <br>
: out std_logic;<br>
 o_en      <br>
o_we      <br>
o_data    <br>
);<br>
 : out std_logic;<br>
 : out std_logic;<br>
 : out std_logic_vector (7 downto 0)<br>
 end project_reti_logiche;<br><br>
 In particolare:<br>
 ● il nome del modulo deve essere project_reti_logiche<br>
 ● i_clk è il segnale di CLOCK in ingresso generato dal TestBench;<br>
 ● i_rst è il segnale di RESET che inizializza la macchina pronta per ricevere il primo segnale di START;<br>
 ● i_start è il segnale di START generato dal Test Bench;<br>
 ● i_data è il segnale (vettore) che arriva dalla memoria in seguito ad una richiesta di lettura;<br>
 ● o_address è il segnale (vettore) di uscita che manda l’indirizzo alla memoria;<br>
 ● o_done è il segnale di uscita che comunica la fine dell’elaborazione e il dato di uscita scritto in memoria;<br>
 ● o_en è il segnale di ENABLE da dover mandare alla memoria per poter comunicare
 (sia in lettura che in scrittura);<br>
 ● o_we è il segnale di WRITE ENABLE da dover mandare alla memoria (=1) per poter
 scriverci. Per leggere da memoria esso deve essere 0;<br>
 ● o_data è il segnale (vettore) di uscita dal componente verso la memoria.
 
# ESEMPI
 La seguente sequenza di numeri mostra un esempio del contenuto della memoria al termine di una elaborazione. I valori che qui sono rappresentati in decimale, sono memorizzati in  memoria con l’equivalente codifica binaria su 8 bit senza segno.<br>
 Esempio1:(Sequenza lunghezza 2)<br>
 W: 10100010  01001011<br>
 Z:  11010001 11001101 11110111 11010010<br>
 INDIRIZZO MEMORIA - VALORE COMMENTO<br>
 0 2 \\ Byte lunghezza sequenza di ingresso<br>
 1 162 \\ primo Byte sequenza da codificare<br>
 2 75<br>
 [...]<br>
 1000 209 \\ primo Byte sequenza di uscita<br>
 1001 205<br>
 1002 247<br>
 1003 210<br><br>
 Esempio2:(Sequenza lunghezza 6)<br>
 W: 10100011 00101111 00000100 01000000 01000011 00001101<br>
 Z: 11010001 11001110 10111101 00100101 10110000 00110111 00110111 00000000<br>
 00110111 00001110 10110000 11101000<br>
 INDIRIZZO MEMORIA       -    VALORE -  COMMENTO<br>
 0 6 \\ Byte lunghezza sequenza di ingresso<br>
 1 163 \\ primo Byte sequenza da codificare<br>
 2 47<br>
 3 4<br>
 4 64<br>
 5 67<br>
 6 13<br>
 [...]<br>
 1000 209 \\ primo Byte sequenza di uscita<br>
 1001 206<br>
 1002 189<br>
 1003 37<br>
 1004 176<br>
 1005 55<br>
 1006 55<br>
 1007 0<br>
 1008 55<br>
 1009 14<br>
 1010 176<br>
 1011 232<br>
 <br>
Esempio3: (Sequenza lunghezza 3)<br>
 W: 01110000 10100100 00101101<br>
 Z:  00111001 10110000 11010001 11110111 00001101 00101000<br>
 INDIRIZZO MEMORIA    - VALORE - COMMENTO      <br>
0 3 \\ Byte lunghezza sequenza di ingresso<br>
 1 112  \\ primo Byte sequenza da codificare<br>
 2 164<br>
 3 45<br>
 [...]<br>
 1000 57  \\ primo Byte sequenza di uscita<br>
 1001 176<br>
 1002 209<br>
 1003 247<br>
 1004 13<br>
 1005 40<br>
 
