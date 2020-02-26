public class FC_UuidUtil {

    private static final String[] CLK_SEQ_HI_RES_PART_1_VALUES = new String[]{
            '8', '9', 'a', 'b'
    };

    /*
     * Returns a Version 4 UUID (as defined in RFC-4122)
     */
    public static String uuidV4() {
        Blob aesKey = Crypto.generateAesKey(128);
        String aesKeyHex = EncodingUtil.convertToHex(aesKey);
        String clkSeqHiResPart1Value =
                CLK_SEQ_HI_RES_PART_1_VALUES[(Math.random() * CLK_SEQ_HI_RES_PART_1_VALUES.size()).intValue()];
        String uuidTemplate = '{0}-{1}-4{2}-{3}{4}-{5}';
        return String.format(uuidTemplate, new String[]{
                aesKeyHex.substring(0, 8),
                aesKeyHex.substring(8, 12),
                aesKeyHex.substring(13, 16),
                clkSeqHiResPart1Value,
                aesKeyHex.substring(17, 20),
                aesKeyHex.substring(20)
        });
    }

}