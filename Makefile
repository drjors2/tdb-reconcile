
.SECONDARY:


LEDGER=mtb-work.ledger


PAYROLLPDFS:=$(wildcard in/M_T*pdf)
PAYROLLTXTS:=$(PAYROLLPDFS:in/%.pdf=sec/%.txt)
PAYROLLCSVS:=$(PAYROLLPDFS:in/%.pdf=sec/%.csv)
PAYROLLLEDGERS:=$(PAYROLLPDFS:in/%.pdf=sec/pay-%.ledger)
PAYROLLLEDGERSDELTA:=$(PAYROLLPDFS:in/%.pdf=sec/delta-%.ledger)

$(info $(PAYROLLPDFS))
$(info $(PAYROLLTXTS))
$(info $(PAYROLLCSVS))
$(info $(PAYROLLLEDGERS))
$(info $(PAYROLLLEDGERSDELTA))



TDBSTATEMENTPDFS:=$(wildcard in/View*pdf)
TDBSTATEMENTTXTS:=$(TDBSTATEMENTPDFS:in/%.pdf=sec/td-%.txt)
TDBSTATEMENTCSVS:=$(TDBSTATEMENTPDFS:in/%.pdf=sec/td-%.csv)
TDBSTATEMENTLEDGERS:=$(TDBSTATEMENTPDFS:in/%.pdf=sec/td-%.ledger)


QFXS:=$(wildcard in/*qfx)
QFXLEDGERDIFF:=$(QFXS:in/%.qfx=sec/delta-qfx-%.ledger)

$(info $(QFXS))
$(info $(QFXLEDGERDIFF))

all: $(PAYROLLLEDGERS) $(TDBSTATEMENTLEDGERS) 


sec/%.txt: in/%.pdf | sec
	pdftotext -layout "$<" "$@"


%.csv: %.txt
	perl bin/tdbank-posting.pl < $<  > $@


# sec/%.csv: sec/%.txt
# 	perl bin/mtb-netpay-csv.pl < $< > $@

# sec/pay-%.ledger: sec/%.csv
# 	ledger-autosync  -d  -a TdBank:USD $< -l $(LEDGER)  | perl -pe 's/\$$(?=\d+)/USD /' >> $@	


sec/td-%.ledger: sec/%.csv
	hledger print --rules-file=bin/tdbank-pdf.csv.rule -f $< |tee $@ >> $(LEDGER)



sec/pay-%.ledger: sec/%.txt
	perl bin/mtb-netpay.pl < $< | tee $@ >> $(LEDGER)


# sec/delta-qfx-%.ledger: in/%.qfx | sec
# 	ledger-autosync -a TdBank:USD -l $(LEDGER) $<   | perl -pe 's/\$$(?=\d+)/USD /'  > $@
# 	cat < $@ >> $(LEDGER)


# netpay:
# 	-rm mtb.ledger
# 	perl bin/mtb-netpay.pl <   > mtb.ledger


# nothing:
# 	@echo all does nothing

extract:
	perl mtb-extractor.pl < M_T_Payroll_Check_Payments_to_Print_-_Report_Design_02_11_2022.txt



sec processed interm:
	mkdir -p $@

clean:
	-rm -rf sec
	rm $(LEDGER)
	touch $(LEDGER)
