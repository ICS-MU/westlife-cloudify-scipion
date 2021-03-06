#!/bin/bash

set -e

OUTPUT=${OUTPUT:-chimera}
PLATFORM=${PLATFORM:-linux_x86_64}
VERSION=${VERSION:-1.11.2}

case "${PLATFORM}" in 
	linux|linux_x86_64)
		SUFF='bin'
		;;
	win32|win64)
		SUFF='exe'
		;;
	mac|mac64)
		SUFF='dmg'
		;;
	*)
		echo "Invalid platform ${PLATFORM}" >&2
		exit 1
esac

BASE_URL=${BASE_URL:-https://www.cgl.ucsf.edu}
FILENAME="chimera-${VERSION}-${PLATFORM}.${SUFF}"
ACCEPT_URL="${BASE_URL}/chimera/cgi-bin/secure/chimera-get.py?file=${PLATFORM}/${FILENAME}"

# show license
cat - <<EOF
-----------------------------------------------------------------------------
Download UCSF Chimera

PLEASE READ THIS SOFTWARE LICENSE AGREEMENT CAREFULLY BEFORE PRESSING THE "ACCEPT" BUTTON DISPLAYED BELOW AND DOWNLOADING THE SOFTWARE. BY PRESSING THE "ACCEPT" BUTTON, YOU ARE AGREEING TO BE BOUND BY THE TERMS OF THIS LICENSE. IF YOU DO NOT AGREE TO THE TERMS OF THIS LICENSE, PRESS THE "DECLINE" BUTTON AND DO NOT USE THE SOFTWARE.

UCSF Chimera Non-Commercial Software License Agreement

This license agreement ("License"), effective today, is made by and between you ("Licensee") and The Regents of the University of California, a California corporation having its statewide administrative offices at 1111 Franklin Street, Oakland, California 94607-5200 ("The Regents"), acting through its Office of Innovation, Technology & Alliances, University of California San Francisco ("UCSF"), 3333 California Street, Suite S-11, San Francisco, California 94143, and concerns certain software known as "UCSF Chimera," a system of software programs for the visualization and interactive manipulation of molecular models, developed by the Computer Graphics Laboratory at UCSF for research purposes and includes executable code, source code, and documentation ("Software").

1. General. A non-exclusive, nontransferable, perpetual license is granted to the Licensee to install and use the Software for academic, non-profit, or government-sponsored research purposes. Use of the Software under this License is restricted to non-commercial purposes. Commercial use of the Software requires a separately executed written license agreement.
2. Permitted Use and Restrictions. Licensee agrees that it will use the Software, and any modifications, improvements, or derivatives to the Software that the Licensee may create (collectively, "Improvements") solely for internal, non-commercial purposes and shall not distribute or transfer the Software or Improvements to any person or third parties without prior written permission from The Regents. The term "non-commercial," as used in this License, means academic or other scholarly research which (a) is not undertaken for profit, or (b) is not intended to produce works, services, or data for commercial use, or (c) is neither conducted, nor funded, by a person or an entity engaged in the commercial use, application or exploitation of works similar to the Software.
3. Ownership and Assignment of Copyright. The Licensee acknowledges that The Regents hold copyright in the Software and associated documentation, and the Software and associated documentation are the property of The Regents. The Licensee agrees that any Improvements made by Licensee shall be subject to the same terms and conditions as the Software. Licensee agrees not to assert a claim of infringement in Licensee copyrights in Improvements in the event The Regents prepares substantially similar modifications or derivative works. The Licensee agrees to use his/her reasonable best efforts to protect the contents of the Software and to prevent unauthorized disclosure by its agents, officers, employees, and consultants. If the Licensee receives a request to furnish all or any portion of the Software to a third party, Licensee will not fulfill such a request but will refer the third party to the UCSF Chimera web page so that the third party's use of this Software will be subject to the terms and conditions of this License. Notwithstanding the above, Licensee may disclose any Improvements that do not involve disclosure of the Software.
4. Copies. The Licensee may make a reasonable number of copies of the Software for the purposes of backup, maintenance of the Software or the development of derivative works based on the Software. These additional copies shall carry the copyright notice and shall be controlled by this License, and will be destroyed along with the original by the Licensee upon termination of the License.
5. Acknowledgement. Licensee agrees that any publication of results obtained with the Software will acknowledge its use by an appropriate citation as specified in the documentation.
6. Disclaimer of Warranties and Limitation of Liability. THE LICENSEE AGREES THAT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. THE REGENTS MAKES NO REPRESENTATION OR WARRANTY THAT THE SOFTWARE WILL NOT INFRINGE ANY PATENT OR OTHER PROPRIETARY RIGHT. IN NO EVENT SHALL THE REGENTS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
7. Termination. This License is effective until terminated by either party. Licensee's rights under this License will terminate automatically without notice from The Regents if Licensee fails to comply with any term(s) of this License. Licensee may terminate the License by giving written notice of termination to The Regents. Upon termination of this License, Licensee shall immediately discontinue all use of the Software and destroy the original and all copies, full or partial, of the Software, including any modifications or derivative works, and associated documentation.
8. Governing Law and General Provisions. This License shall be governed by the laws of the State of California, excluding the application of its conflicts of law rules. This License shall not be governed by the United Nations Convention on Contracts for the International Sale of Goods, the application of which is expressly excluded. If any provisions of this License are held invalid or unenforceable for any reason, the remaining provisions shall remain in full force and effect. This License is binding upon any heirs and assigns of the Licensee. The License granted to Licensee hereunder may not be assigned or transferred to any other person or entity without the express consent of The Regents. This License constitutes the entire agreement between the parties with respect to the use of the Software licensed hereunder and supersedes all other previous or contemporaneous agreements or understandings between the parties, whether verbal or written, concerning the subject matter. Any translation of this License is done for local requirements and in the event of a dispute between the English and any non-English versions, the English version of this License shall govern.

Revised 28jan04
-----------------------------------------------------------------------------

LICENSE AGREEMENT WILL BE AUTOMATICALLY ACCEPTED IN 20 SECONDS.
TO REFUSE THE LICENSE YOU MUST STOP THE SCRIPT BY PRESSING CTRL+C.
EOF

for i in {1..20}; do
    sleep 1
	echo -n .
done

# accept software license agreement and
# get download URI in meta refresh tag
DOWNLOAD_URI=$(curl -s --data 'choice=Accept' "${ACCEPT_URL}" | \
	grep -F 'http-equiv="Refresh"' |  \
	sed -e 's/.*url=\(.*\)">/\1/')

if [ -z "${DOWNLOAD_URI}" ]; then
	echo "Invalid download URI ${DOWNLOAD_URI}" >&2
	exit 1
fi

# download chimera
test -e "${OUTPUT}" && unlink "${OUTPUT}"
curl -o "${OUTPUT}" "${BASE_URL}${DOWNLOAD_URI}"
chmod a+x "${OUTPUT}"
